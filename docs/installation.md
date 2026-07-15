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

### Using Release Binaries

Each tagged release ships binaries for Linux, macOS, and Windows
(amd64/arm64) with a `checksums.txt` (sha256):

```bash
curl -LO https://github.com/wbatchayon/kubeops/releases/latest/download/kubeops-linux-amd64.tar.gz
curl -LO https://github.com/wbatchayon/kubeops/releases/latest/download/checksums.txt
sha256sum --check --ignore-missing checksums.txt
tar -xzf kubeops-linux-amd64.tar.gz
sudo mv kubeops /usr/local/bin/
```

### Using the Container Image

The CLI is also published to GitHub Packages:

```bash
docker run --rm ghcr.io/wbatchayon/kubeops:latest version
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
