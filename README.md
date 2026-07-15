![logo](docs/assets/KubeOps.png)

[![CI Pipeline](https://github.com/wbatchayon/kubeops/actions/workflows/ci.yaml/badge.svg)](https://github.com/wbatchayon/kubeops/actions/workflows/ci.yaml)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![Go Version](https://img.shields.io/badge/Go-1.21+-00ADD8.svg)](https://golang.org)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-1.28+-326CE5.svg)](https://kubernetes.io)

> Kubernetes cluster deployment on Proxmox using Cluster API, Argo CD, Terraform, Ansible, and more.

## Quick Start

```bash
# Install CLI
go install github.com/wbatchayon/kubeops/cmd/kubeops@latest

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
- **Registry**: Harbor (air-gapped proxy cache)
- **Security**: OpenBao, cert-manager internal PKI, RBAC, 443-only exposure
- **Monitoring**: Prometheus + Grafana

## Documentation

See [docs/](docs/) for detailed documentation:

- [Architecture](docs/architecture.md)
- [Installation](docs/installation.md)
- [Configuration](docs/configuration.md)
- [Air-Gapped Deployment](docs/airgap.md)
- [CLI Reference](docs/cli-reference.md)
- [CI/CD Pipeline](docs/cicd.md)
- [Security](docs/SECURITY.md)
- [Contributing](CONTRIBUTING.md)
- [Changelog](CHANGELOG.md)
- [Roadmap](plans/ROADMAP.md)

## Requirements

See [Installation — Prerequisites](docs/installation.md#prerequisites) for
the full list of required tools and versions.

## License

Apache 2.0 - See [LICENSE](LICENSE)
