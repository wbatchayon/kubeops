# CI/CD Pipeline

This document describes the KubeOps CI/CD pipeline.

## Overview

KubeOps uses GitHub Actions for continuous integration and deployment with 12 stages.

## Pipeline Stages

| # | Stage | Description | Details |
|---|-------|-------------|---------|
| 1 | Validation | YAML, Go fmt/vet validation | Validates all configuration files: YAML syntax, Terraform format, Go code formatting |
| 2 | Build | Binary compilation | Compiles for multiple platforms (Linux, macOS, Windows); Runs tests without network |
| 3 | Unit Tests | Go unit tests with coverage | Executes Go unit tests with coverage reporting and short mode tests |
| 4 | Integration Tests | Terraform, Ansible, K8s integration | Runs integration tests for Terraform, Ansible, and Kubernetes |
| 5 | Security | Trivy vulnerability scanning | Trivy vulnerability scanner, CodeQL analysis, and dependency scanning |
| 6 | Terraform | Terraform format and validate | Validates Terraform format and configuration |
| 7 | Ansible Lint | Ansible playbooks validation | Validates Ansible playbooks syntax and best practices |
| 8 | Packaging | Multi-platform binaries | Creates release artifacts: binaries, container images, and Helm charts |
| 9 | E2E Tests | End-to-end tests | Full cluster deployment, application deployment, and monitoring verification |
| 10 | Deploy Test | Test environment deployment | Spins up test cluster, runs smoke tests and integration tests |
| 11 | Monitoring | Health checks | Cluster API availability, node status, and pod health checks |
| 12 | Feedback | Build reports, Slack notifications | Build notifications, deployment status, and metrics collection |

## Workflow Triggers

```yaml
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]
  release:
    types: [published]
```

## Environment Configuration

| Environment | Trigger | Description |
|-------------|---------|-------------|
| Dev | Push to develop | Development testing |
| Staging | PR to main | Pre-production |
| Production | Release | Production deployment |

## Required Secrets

Configure these GitHub secrets:

| Secret | Description |
|--------|-------------|
| `PM_API_URL` | Proxmox API URL |
| `PM_API_TOKEN_ID` | Proxmox token ID |
| `PM_API_TOKEN_SECRET` | Proxmox token secret |
| `VAULT_ADDR` | Vault server address |
| `VAULT_TOKEN` | Vault token |
| `GITHUB_TOKEN` | GitHub API token |

## Running Locally

```bash
# Run validation
make validate

# Run tests
make test

# Run integration tests
make test-integration
```

## Monitoring

Access pipeline metrics:
- GitHub Actions dashboard
- Prometheus metrics endpoint
- Grafana CI/CD dashboard
