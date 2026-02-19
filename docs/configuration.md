# Configuration

This guide explains how to configure KubeOps for your environment.

## Configuration File

Create `~/.kubeops/kubeops.yaml`:

```yaml
proxmox:
  url: "https://proxmox:8006/api2/json"
  node: "pve"
  token_id: "username@pam!token"
  token_secret: "your-secret"
  cluster:
    name: "kubeops"
    kubernetes-version: "v1.28.0"
    pod-cidr: "10.244.0.0/16"
    service-cidr: "10.96.0.0/16"
    control-plane:
      replicas: 3
      cpu: 4
      memory: 8192
      disk: 50
    worker:
      replicas: 3
      cpu: 4
      memory: 8192
      disk: 100
  network:
    bridge: "vmbr0"
    vlan: 100
    gateway: "192.168.1.1"
    ip-start: "192.168.1.50"
    ip-end: "192.168.1.100"
    dns-servers:
      - "8.8.8.8"
      - "8.8.4.4"
  ssh:
    user: "ubuntu"
    authorized_keys:
      - "ssh-rsa AAAAB3Nza..."
    password: "changeme"

vault:
  address: "http://vault:8200"
  token: "your-vault-token"
  secret-engine: "kubernetes"

argo-cd:
  address: "http://argocd:8080"
  admin_password: "changeme"
  server_url: "https://argocd.example.com"

monitoring:
  prometheus:
    retention: "15d"
    storage: "50Gi"
  grafana:
    admin_password: "admin"
    persistence: true
```

## Environment Variables

### Proxmox

```bash
export PM_API_URL="https://proxmox:8006/api2/json"
export PM_API_TOKEN_ID="username@pam!token"
export PM_API_TOKEN_SECRET="uuid-secret"
```

### Vault

```bash
export VAULT_ADDR="http://vault:8200"
export VAULT_TOKEN="token"
```

### Argo CD

```bash
export ARGOCD_SERVER="argocd:8080"
export ARGOCD_AUTH_TOKEN="token"
```

## Terraform Variables

Edit `terraform/environments/dev/terraform.tfvars`:

```hcl
proxmox = {
  url           = "https://proxmox:8006/api2/json"
  user          = "root@pam"
  token_id      = "username@pam!token"
  token_secret  = "secret"
  node          = "pve"
}

cluster = {
  name               = "kubeops"
  kubernetes_version = "1.28.0"
  pod_cidr          = "10.244.0.0/16"
  service_cidr      = "10.96.0.0/16"
}

control_plane = {
  count        = 3
  cpu         = 4
  memory      = 8192
  disk_size   = 50
}

worker = {
  count        = 3
  cpu         = 4
  memory      = 8192
  disk_size   = 100
}
```

## Next Steps

- [CLI Reference](cli-reference.md)
- [CI/CD Pipeline](cicd.md)
