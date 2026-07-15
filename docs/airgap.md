# Air-Gapped Deployment

This guide explains how KubeOps runs without internet access. Two rules
drive the design:

1. **Nothing is fetched from the internet at deploy time.** Every container
   image, Helm chart, and OS package comes from infrastructure inside the
   perimeter.
2. **Only 443/HTTPS is exposed.** External traffic enters through the
   Gateway's single HTTPS listener; everything else is dropped by the node
   firewall.

## Components

| Need | Solution | Where |
|------|----------|-------|
| Container images | Harbor pull-through proxy cache | `harbor/`, containerd mirrors in `ansible/roles/containerd/` |
| Helm charts | Harbor OCI project `charts` | Argo CD sources point at `harbor.kubeops.local/charts` |
| OS / Kubernetes packages | Internal mirror of `pkgs.k8s.io` | `common_kubernetes_repo_base_url` variable |
| containerd binary | Internal artifact server | `containerd_release_url` variable |
| TLS certificates | Internal PKI (OpenBao + cert-manager CA issuer) | `cert-manager/`, `openbao/` |
| Node trust of the internal CA | Trust-store distribution | `common_internal_ca_cert` variable |

## Seeding Harbor (from a connected bastion)

Harbor itself runs in the cluster, so the very first installation is done
from a bastion that has temporary internet access (or from artifacts
carried across the perimeter).

1. **Create the Harbor projects:**
   - One **proxy-cache project per upstream registry**, named exactly after
     the upstream host: `docker.io`, `quay.io`, `registry.k8s.io`,
     `ghcr.io`. The containerd mirror configuration
     (`/etc/containerd/certs.d/<upstream>/hosts.toml`) relies on this
     naming convention.
   - One regular **`charts` project** for Helm charts (OCI).

2. **Seed the Helm charts** consumed by Argo CD:

   ```bash
   for chart in cilium/cilium:1.14.5 \
                prometheus-community/kube-prometheus-stack:55.5.0 \
                jetstack/cert-manager:v1.13.6 \
                harbor/harbor:1.14.2; do
     name="${chart%%:*}"; version="${chart##*:}"
     helm pull "$name" --version "$version"
     helm push "${name##*/}-${version}.tgz" oci://harbor.kubeops.local/charts
   done
   ```

3. **Preload the bootstrap images** on the nodes. The cluster's own
   bootstrap (kubeadm, Cilium) happens before Harbor is running inside it,
   so those images must be imported directly into containerd:

   ```bash
   kubeadm config images list --kubernetes-version v1.28.0 > images.txt
   # plus quay.io/cilium/cilium:v1.14.5 and the Argo CD / Harbor images
   for img in $(cat images.txt); do crane pull "$img" "$(basename "$img").tar"; done
   # on each node:
   ctr -n k8s.io images import <image>.tar
   ```

   After Harbor is up and seeded, day-2 pulls flow through the proxy cache.

## Package mirror

The nodes install kubeadm/kubelet/kubectl from an internal mirror that
reproduces the `pkgs.k8s.io` layout (Nexus, Artifactory, or `apt-mirror`),
and download the containerd tarball from an internal artifact server.
Point the Ansible variables at them (inventory or group_vars):

```yaml
common_kubernetes_repo_base_url: "https://mirror.kubeops.local/pkgs.k8s.io"
containerd_release_url: "https://mirror.kubeops.local/containerd/v1.7.13"
```

## Internal PKI

Let's Encrypt/ACME cannot work without internet access. Certificates are
issued by cert-manager's `kubeops-ca` ClusterIssuer, backed by an
intermediate CA from OpenBao's PKI engine:

1. Initialize the OpenBao PKI engine (root + intermediate) — the
   `pki_int/` paths are already covered by `openbao/policies/`.
2. Export the intermediate and create the issuer secret (out-of-band,
   never in git):

   ```bash
   kubectl create secret tls kubeops-ca-root -n cert-manager \
     --cert=intermediate-ca.pem --key=intermediate-ca-key.pem
   ```

3. Distribute the CA certificate to the node trust stores so containerd
   trusts the Harbor mirror:

   ```yaml
   common_internal_ca_cert: "{{ lookup('file', 'files/kubeops-ca.pem') }}"
   ```

4. Import the CA into the browsers/OS of clients that consume the
   Gateway's services.

## Network openings

| Port | Protocol | Source | Purpose |
|------|----------|--------|---------|
| 443 | TCP | any | Gateway HTTPS listener (the only public entry point) |
| 22 | TCP | admin network | SSH (Ansible) |
| 6443 | TCP | admin network + pods | Kubernetes API |
| all | — | node + pod networks | Intra-cluster (etcd, kubelet, Cilium VXLAN/WireGuard) |

Everything else is dropped by the nftables policy
(`ansible/roles/firewall/`). There is **no port 80**: the Gateway has no
HTTP listener, not even for a redirect — clients must use `https://`.

Set `firewall_admin_cidr` to the bastion/VPN range in production; it
defaults to the node network.

## Known limitations

- **GitOps source**: the Argo CD applications still reference
  `github.com/wbatchayon/kubeops.git`. A fully air-gapped cluster needs an
  internal git mirror (e.g. Gitea) — tracked in the
  [roadmap](../plans/ROADMAP.md).
- **DNS**: `harbor.kubeops.local` (and the other Gateway hostnames) must
  resolve to the Gateway address via internal DNS.
- **Harbor's embedded Trivy is disabled** (its vulnerability database
  needs internet); image scanning happens in CI instead.
