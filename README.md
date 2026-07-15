![logo](docs/assets/KubeOps.png)

[![CI Pipeline](https://github.com/wbatchayon/kubeops/actions/workflows/ci.yaml/badge.svg)](https://github.com/wbatchayon/kubeops/actions/workflows/ci.yaml)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![Go Version](https://img.shields.io/badge/Go-1.21+-00ADD8.svg)](https://golang.org)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-1.28+-326CE5.svg)](https://kubernetes.io)

> Kubernetes cluster deployment on Proxmox using Cluster API, Argo CD, Terraform, Ansible, and more.

## Quick Start

```bash
git clone https://github.com/wbatchayon/kubeops.git
cd kubeops

# 1. Provision the VMs on Proxmox
cd terraform/environments/dev
cp terraform.tfvars.example terraform.tfvars   # edit, then:
terraform init && terraform apply

# 2. Configure the nodes and bootstrap Kubernetes
cd ../../../ansible
ansible-playbook -i inventory/hosts.yaml playbooks/bootstrap.yaml

# 3. Install Cilium + Argo CD, then GitOps takes over
# -> follow docs/deployment.md for the complete procedure
```

The full walkthrough — including the GitOps handover, secrets, and
verification steps — is in the [deployment guide](docs/deployment.md).
The `kubeops` CLI that will orchestrate these steps is
[in progress](plans/ROADMAP.md).

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
- [Deployment Guide](docs/deployment.md)
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
