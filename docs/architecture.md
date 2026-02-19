# Architecture

This document describes the KubeOps architecture and components.

## Overview

KubeOps is a Kubernetes cluster deployment tool for Proxmox using Infrastructure as Code (IaC) and GitOps practices.

## Architecture Diagram

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
| Secrets | Vault | Secret management |

### Monitoring Layer

| Component | Technology | Purpose |
|-----------|------------|---------|
| Metrics | Prometheus | Time-series data |
| Dashboards | Grafana | Visualization |
| Alerts | AlertManager | Notification |

## Directory Structure

```
kubeops/
├── ansible/              # Configuration management
│   ├── playbooks/       # Ansible playbooks
│   └── roles/          # Ansible roles
├── argocd/             # Argo CD configurations
├── cilium/             # Cilium CNI configs
├── cluster-api/        # Cluster API manifests
├── gateway-api/        # Gateway API configs
├── helm-charts/        # Helm charts
├── monitoring/         # Prometheus/Grafana
├── terraform/          # Infrastructure as Code
└── .github/workflows/  # CI/CD pipelines
```
