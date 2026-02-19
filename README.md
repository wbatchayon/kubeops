# KubeOps

![logo](KubeOps.png)

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![Go Version](https://img.shields.io/badge/Go-1.21+-00ADD8.svg)](https://golang.org)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-1.28+-326CE5.svg)](https://kubernetes.io)

> Kubernetes cluster deployment on Proxmox using Cluster API, Argo CD, Terraform, Ansible, and more.

## Quick Start

```bash
# Install CLI
go install github.com/kubeops/kubeops@latest

# Initialize cluster
kubeops init --name mycluster --kubernetes-version v1.28.0

# Deploy
kubeops deploy
```

## Features

- **Infrastructure**: Terraform + Ansible for Proxmox
- **Kubernetes**: Cluster API, KubeadmControlPlane
- **Networking**: Cilium CNI, Gateway API
- **GitOps**: Argo CD, Helm
- **Security**: Vault, RBAC
- **Monitoring**: Prometheus + Grafana

## Documentation

See [docs/](docs/) for detailed documentation:

- [Architecture](docs/architecture.md)
- [Installation](docs/installation.md)
- [Configuration](docs/configuration.md)
- [CLI Reference](docs/cli-reference.md)
- [CI/CD Pipeline](docs/cicd.md)
- [Security](docs/SECURITY.md)
- [Contributing](docs/CONTRIBUTING.md)

## Requirements

| Tool | Version |
|------|---------|
| Go | 1.21+ |
| Terraform | 1.6+ |
| Ansible | 2.14+ |
| Kubernetes | 1.28+ |

## License

Apache 2.0 - See [LICENSE](LICENSE)
