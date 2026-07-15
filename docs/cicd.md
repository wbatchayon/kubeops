# CI/CD Pipeline

This document describes the KubeOps CI pipeline, defined in
[`.github/workflows/ci.yaml`](../.github/workflows/ci.yaml).

## Overview

KubeOps uses GitHub Actions for continuous integration with 12 stages.
Stages 4, 9, 10, and 11 are currently placeholders: they run but skip or
no-op until the corresponding test suites and environments exist (see the
[roadmap](../plans/ROADMAP.md)).

## Pipeline Stages

| # | Stage | Depends on | What it does |
|---|-------|------------|--------------|
| 1 | Validation | — | yamllint on all YAML files, `gofmt` check, `go vet` |
| 2 | Build | 1 | Builds the `kubeops` binary and uploads it as an artifact |
| 3 | Unit Tests | 2 | `go test -short` with coverage report artifact |
| 4 | Integration Tests | 3 | Runs build-tagged tests in `test/integration/` (skips while the directory is absent) |
| 5 | Security | 3 | Trivy filesystem scan, SARIF results uploaded to GitHub code scanning |
| 6 | Terraform | 1 | `terraform fmt -check`, then `init`/`validate` on the dev environment |
| 7 | Ansible Lint | 1 | ansible-lint on playbooks and roles (non-blocking for now) |
| 8 | Packaging | 2, 5 | Cross-compiles binaries for Linux, macOS, and Windows |
| 9 | E2E Tests | 8 | Runs build-tagged tests in `test/e2e/` (skips while the directory is absent) |
| 10 | Deploy Test | 6, 7 | Placeholder for test-environment deployment; only runs on `develop` |
| 11 | Monitoring | 10 | Placeholder for post-deployment health checks |
| 12 | Feedback | 11 | Build summary in the run output; Slack notification on failure |

## Workflow Triggers

```yaml
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]
```

The Deploy Test stage (and the Monitoring and Feedback stages that follow it)
additionally requires a push to `develop`.

## Required Secrets

| Secret | Required | Description |
|--------|----------|-------------|
| `SLACK_WEBHOOK_URL` | Optional | Webhook used by the Feedback stage to notify on failure |

No other secrets are consumed by the CI pipeline. Credentials for actual
deployments (Proxmox, OpenBao) are configured locally — see
[Configuration](configuration.md).

## Running Locally

The pipeline mirrors Makefile targets, so every gate can be run before
pushing:

```bash
# Stage 1 equivalents
make validate-all

# Stages 3-4
make test

# Stage 6
make terraform-validate

# Stage 7
make ansible-lint
```
