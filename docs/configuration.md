# Configuration

This guide explains how to configure KubeOps for your environment. There
are three configuration surfaces, used at different stages:

| Surface | File | Consumed by |
|---------|------|-------------|
| Terraform variables | `terraform/environments/<env>/terraform.tfvars` | VM provisioning |
| Ansible inventory | `ansible/inventory/hosts.yaml` | Node configuration |
| CLI configuration | `~/.kubeops/kubeops.yaml` | The `kubeops` CLI |

## Terraform Variables

Copy the example file and adjust it:

```bash
cd terraform/environments/dev
cp terraform.tfvars.example terraform.tfvars
```

The example documents every variable (`proxmox`, `cluster`,
`control_plane`, `worker`, `network`, `ssh`). Keep credentials out of the
file — the provider reads them from the environment:

```bash
export PM_API_URL="https://proxmox:8006/api2/json"
export PM_API_TOKEN_ID="username@pam!token"
export PM_API_TOKEN_SECRET="uuid-secret"
```

`terraform.tfvars` is gitignored: never commit it.

## Ansible Inventory

Edit `ansible/inventory/hosts.yaml` with the addresses of the VMs created
by Terraform. The defaults worth knowing:

```yaml
all:
  vars:
    kubernetes_version: "1.28.0"
    pod_network_cidr: "10.244.0.0/16"
    service_cidr: "10.96.0.0/16"
    ansible_user: ubuntu
    ansible_ssh_private_key_file: ~/.ssh/id_rsa
```

Variables you may need to override (inventory `vars` or `group_vars`):

| Variable | Default | Purpose |
|----------|---------|---------|
| `kubeadm_control_plane_endpoint` | first control-plane address | Set to a VIP/load-balancer for real HA |
| `firewall_admin_cidr` | node network | Network allowed to reach SSH (22) and the API (6443) |
| `common_kubernetes_repo_base_url` | `https://pkgs.k8s.io` | Internal package mirror (airgap) |
| `containerd_registry_mirror_host` | `harbor.kubeops.local` | Harbor proxy cache; `""` disables mirroring |
| `common_internal_ca_cert` | empty | PEM of the internal CA to trust (airgap) |

See [Air-Gapped Deployment](airgap.md) for the airgap-specific values.

## CLI Configuration

The `kubeops` CLI reads `kubeops.yaml` from `~/.kubeops/` or the current
directory (or the path given with `--config`). All keys are top-level:

```yaml
proxmox:
  url: "https://proxmox:8006/api2/json"
  node: "pve"

cluster:
  name: "kubeops"
  kubernetes-version: "v1.28.0"
  control-plane:
    replicas: 3
  worker:
    replicas: 3

openbao:
  address: "https://openbao:8200"

argo-cd:
  address: "https://argocd:8080"
```

Anything not listed above is not read by the CLI today (see the
[CLI reference](cli-reference.md) for the current command status).

## Environment Variables

### Proxmox

```bash
export PM_API_URL="https://proxmox:8006/api2/json"
export PM_API_TOKEN_ID="username@pam!token"
export PM_API_TOKEN_SECRET="uuid-secret"
```

### OpenBao

```bash
export BAO_ADDR="https://openbao:8200"
export BAO_TOKEN="token"
```

The `bao` CLI also honors the legacy `VAULT_ADDR`/`VAULT_TOKEN` variables
for compatibility with existing tooling.

### Argo CD

```bash
export ARGOCD_SERVER="argocd:8080"
export ARGOCD_AUTH_TOKEN="token"
```

## Secrets

Never put real credentials in configuration files that live in git.
Tokens and passwords belong in environment variables or OpenBao; the
cluster-side secrets (`grafana-admin`, `harbor-admin`, `kubeops-ca-root`,
Proxmox credentials for Cluster API) are created out-of-band as described
in the [deployment guide](deployment.md).

## Next Steps

- [Deployment](deployment.md)
- [CLI Reference](cli-reference.md)
- [CI/CD Pipeline](cicd.md)
