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
git clone https://github.com/wbatchayon/kubeops.git
cd kubeops
make build
sudo mv bin/kubeops /usr/local/bin/
```

### Using Go Install

```bash
go install github.com/wbatchayon/kubeops/cmd/kubeops@latest
```

> **Note:** Pre-built release binaries and a Homebrew formula will be
> provided with the first tagged release (see the
> [roadmap](../plans/ROADMAP.md)). Until then, install from source or with
> `go install`.

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
