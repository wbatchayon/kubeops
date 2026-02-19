# Installation

This guide covers installing KubeOps and its prerequisites.

## Prerequisites

| Tool | Version | Installation |
|------|---------|--------------|
| Go | 1.21+ | [golang.org](https://golang.org) |
| Terraform | 1.6+ | [terraform.io](https://www.terraform.io) |
| Ansible | 2.14+ | [ansible.com](https://www.ansible.com) |
| kubectl | 1.28+ | [kubernetes.io](https://kubernetes.io) |
| helm | 3.12+ | [helm.sh](https://helm.sh) |
| clusterctl | 1.5+ | [cluster-api.sigs.k8s.io](https://cluster-api.sigs.k8s.io) |

## Install KubeOps CLI

### From Source

```bash
git clone https://github.com/kubeops/kubeops.git
cd kubeops
make build
sudo mv bin/kubeops /usr/local/bin/
```

### Using Go Install

```bash
go install github.com/kubeops/kubeops@latest
```

### Using Homebrew

```bash
brew install kubeops
```

### Using Binaries

```bash
# Linux
curl -L https://github.com/kubeops/kubeops/releases/latest/download/kubeops-linux-amd64 -o kubeops
chmod +x kubeops
sudo mv kubeops /usr/local/bin/

# macOS
curl -L https://github.com/kubeops/kubeops/releases/latest/download/kubeops-darwin-amd64 -o kubeops
chmod +x kubeops
sudo mv kubeops /usr/local/bin/
```

## Verify Installation

```bash
kubeops version
kubeops --help
```

## Proxmox Setup

1. Create a Proxmox VE cluster
2. Generate API token:
   - Datacenter → API Tokens → Add
   - Note the token ID and secret
3. Ensure network connectivity to Proxmox API (port 8006)

## Next Steps

- [Configuration](configuration.md)
- [CLI Reference](cli-reference.md)
