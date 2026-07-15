# Architecture

This document describes the KubeOps architecture and components.

## Overview

KubeOps is a Kubernetes cluster deployment tool for Proxmox using Infrastructure as Code (IaC) and GitOps practices.

## Architecture Diagram

![KubeOps architecture](assets/KubeOps.png)

## Components

### Infrastructure Layer

| Component | Technology | Purpose |
|-----------|------------|---------|
| Provisioning | Terraform | VM creation on Proxmox |
| Configuration | Ansible | Node setup and configuration |
| Templates | Cloud-Init | VM initialization |

### Kubernetes Layer

| Component | Technology | Purpose |
|-----------|------------|---------|
| Cluster API | clusterctl | Kubernetes lifecycle management |
| Control Plane | KubeadmControlPlane | API server, etcd |
| Workers | MachineDeployment | Worker node management |

### Networking Layer

| Component | Technology | Purpose |
|-----------|------------|---------|
| CNI | Cilium | Pod networking |
| Observability | Hubble | Network visibility |
| Ingress | Gateway API | External access |

### GitOps Layer

| Component | Technology | Purpose |
|-----------|------------|---------|
| CD | Argo CD | Continuous deployment |
| Packaging | Helm | Application manifests |
| Secrets | OpenBao | Secret management |
| Registry | Harbor | Private registry and proxy cache (airgap) |
| PKI | cert-manager + OpenBao | Internal TLS certificates |

### Monitoring Layer

| Component | Technology | Purpose |
|-----------|------------|---------|
| Metrics | Prometheus | Time-series data |
| Dashboards | Grafana | Visualization |
| Alerts | AlertManager | Notification |

## Repository Layout

```
kubeops/
├── .github/workflows/   # CI pipeline (GitHub Actions)
├── ansible/             # Node configuration
│   ├── inventory/       # Inventory templates
│   ├── playbooks/       # Ansible playbooks
│   └── roles/           # Ansible roles
├── argo-cd/             # Argo CD bootstrap, projects, and applications
├── cert-manager/        # Internal PKI (CA ClusterIssuer)
├── cilium/              # Cilium CNI Helm values
├── cluster-api/         # Cluster API manifests
├── cmd/kubeops/         # Go CLI entry point
├── docs/                # Project documentation
├── gateway-api/         # Gateway API resources
├── harbor/              # Harbor private registry (airgap proxy cache)
├── helm-charts/         # Helm charts
├── monitoring/          # Prometheus/Grafana configuration
├── openbao/             # OpenBao policies
├── pkg/                 # Go packages
├── plans/               # Design documents and roadmap
├── terraform/           # Proxmox infrastructure
│   ├── environments/    # Per-environment configurations
│   └── modules/         # compute, network, storage modules
└── test/                # Test suites
```

Each directory is self-contained so the full stack can be reproduced from a
fresh clone: provision with `terraform/`, configure nodes with `ansible/`,
create the cluster with `cluster-api/`, then let Argo CD reconcile everything
under `argo-cd/`, `cilium/`, `gateway-api/`, `helm-charts/`, and
`monitoring/`. See [Installation](installation.md) for the step-by-step
procedure, and [Air-Gapped Deployment](airgap.md) for running without
internet access (Harbor registry, internal PKI, 443-only exposure).
