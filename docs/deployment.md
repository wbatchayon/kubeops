# Deployment Guide

End-to-end procedure to go from a fresh clone to a running cluster.

> **Note:** the `kubeops` CLI does not orchestrate these steps yet (see
> the [CLI reference](cli-reference.md)); the deployment is driven by
> Terraform, Ansible, and Helm directly. For a deployment without
> internet access, read [Air-Gapped Deployment](airgap.md) first — it
> changes where images, charts, and packages come from.

## Prerequisites

- The [tools](installation.md#prerequisites) installed on your workstation
- A Proxmox VE host with an API token
  ([installation guide](installation.md#proxmox-setup))
- A cloud-init-enabled VM template on the Proxmox node (Ubuntu 22.04
  recommended — its kernel supports Cilium's WireGuard encryption)

## 1. Provision the VMs (Terraform)

```bash
cd terraform/environments/dev
cp terraform.tfvars.example terraform.tfvars   # then edit it
export PM_API_TOKEN_ID="username@pam!token"
export PM_API_TOKEN_SECRET="uuid-secret"
terraform init
terraform plan
terraform apply
```

Verify: the control-plane and worker VMs are visible in Proxmox and
reachable over SSH.

## 2. Configure the nodes (Ansible)

Update `ansible/inventory/hosts.yaml` with the VM addresses, then:

```bash
cd ansible
ansible-galaxy collection install -r requirements.yml
ansible-playbook -i inventory/hosts.yaml playbooks/bootstrap.yaml
ansible-playbook -i inventory/hosts.yaml playbooks/kubeconfig.yaml
```

The bootstrap playbook installs containerd and kubeadm, applies the node
firewall (default drop — only 443 public, SSH/API from
`firewall_admin_cidr`), initializes the first control plane, and joins
the other nodes.

Verify:

```bash
export KUBECONFIG=~/.kube/kubeops-config
kubectl get nodes   # all nodes listed; NotReady is expected (no CNI yet)
```

## 3. Install the CNI (Cilium)

Argo CD manages Cilium day-2, but the very first install happens from
your workstation (pods cannot start without a CNI):

```bash
helm repo add cilium https://helm.cilium.io
helm install cilium cilium/cilium --version 1.14.5 \
  --namespace kube-system -f cilium/base/values.yaml
```

Verify: `kubectl get nodes` reports `Ready` on every node.

## 4. Install Argo CD and hand over

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm install argocd argo/argo-cd \
  --namespace argocd --create-namespace -f argo-cd/base/values.yaml

kubectl apply -f argo-cd/projects/kubeops-project.yaml
kubectl apply -f argo-cd/applications/kubeops-root.yaml
```

The root application (app-of-apps) then reconciles everything under
`argo-cd/apps/`: Cilium (adopting the manual install), Gateway API,
cert-manager, Harbor, and the monitoring stack.

## 5. Create the out-of-band secrets

These are never committed to git:

```bash
# Grafana admin credentials
kubectl create secret generic grafana-admin -n monitoring \
  --from-literal=admin-user=admin --from-literal=admin-password='<password>'

# Harbor admin password
kubectl create secret generic harbor-admin -n harbor \
  --from-literal=HARBOR_ADMIN_PASSWORD='<password>'

# Internal CA for cert-manager (see docs/airgap.md for the OpenBao PKI flow)
kubectl create secret tls kubeops-ca-root -n cert-manager \
  --cert=intermediate-ca.pem --key=intermediate-ca-key.pem
```

## 6. Verify the deployment

```bash
kubectl get applications -n argocd        # all Synced/Healthy
kubectl get gateway -n kube-system        # kubeops-gateway Programmed
kubectl -n kube-system exec ds/cilium -- cilium status --brief
kubectl get certificates -A               # kubeops-tls Ready
```

Access to the services goes exclusively through the Gateway on **443**
(there is no HTTP listener): point your DNS entries — e.g.
`harbor.kubeops.local` — at the Gateway address and import the internal
CA into your trust store.

## Teardown

```bash
cd terraform/environments/dev
terraform destroy
```

## Known gaps

Tracked in the [roadmap](../plans/ROADMAP.md): the `${...}` placeholders
in the Cluster API manifests still need a render step, the control plane
has no VIP yet (the first node's address is the API endpoint), and
OpenBao itself is not deployed by an application yet.
