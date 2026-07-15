# CI/CD Pipeline

This document describes the KubeOps CI pipeline, defined in
[`.github/workflows/ci.yaml`](../.github/workflows/ci.yaml).

## Overview

KubeOps uses GitHub Actions for continuous integration with 14 stages.
Stages 6, 11, 12, and 13 are currently placeholders: they run but skip or
no-op until the corresponding test suites and environments exist (see the
[roadmap](../plans/ROADMAP.md)).

The CI runs outside the air-gapped perimeter (GitHub-hosted runners): it
validates code and enforces the airgap rules, but never touches the
cluster. When the Deploy Test and Monitoring stages are implemented, they
will need a self-hosted runner inside the perimeter.

## Pipeline Stages

| # | Stage | Depends on | What it does |
|---|-------|------------|--------------|
| 1 | Validation | — | yamllint on all YAML files, `gofmt` check, `go vet` |
| 2 | Airgap Guard | — | `scripts/airgap-guard.sh`: no external Argo CD sources, no plain HTTP listener, no ACME issuer |
| 3 | Helm Validate | 1 | `helm lint` on local charts, renders vendor charts against our values, kubeconform on raw manifests |
| 4 | Build | 1 | Builds the `kubeops` binary and uploads it as an artifact |
| 5 | Unit Tests | 4 | `go test -short` with coverage report artifact |
| 6 | Integration Tests | 5 | Runs build-tagged tests in `test/integration/` (skips while the directory is absent) |
| 7 | Security | 5 | Trivy filesystem scan, SARIF results uploaded to GitHub code scanning |
| 8 | Terraform | 1 | `terraform fmt -check`, then `init`/`validate` on the dev environment |
| 9 | Ansible Lint | 1 | ansible-lint on playbooks and roles (non-blocking for now) |
| 10 | Packaging | 4, 7 | Cross-compiles binaries for Linux, macOS, and Windows |
| 11 | E2E Tests | 10 | Runs build-tagged tests in `test/e2e/` (skips while the directory is absent) |
| 12 | Deploy Test | 8, 9 | Placeholder for test-environment deployment; only runs on `develop` |
| 13 | Monitoring | 12 | Placeholder for post-deployment health checks |
| 14 | Feedback | 13 | Build summary in the run output; Slack notification on failure |

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

## Release Pipeline

A separate workflow,
[`release.yaml`](../.github/workflows/release.yaml), runs when a `v*` tag
is pushed:

| Job | What it does |
|-----|--------------|
| GoReleaser | GitHub Release with Linux/macOS/Windows (amd64/arm64) binaries, sha256 checksums, and the `ghcr.io/wbatchayon/kubeops` container image |
| Helm Chart | Pushes `base-chart` to `oci://ghcr.io/wbatchayon/charts` |

The release process is described in
[CONTRIBUTING.md](../CONTRIBUTING.md#releases-maintainers).

## Running Locally

The pipeline mirrors Makefile targets, so every gate can be run before
pushing:

```bash
# Stages 1-2 equivalents (includes the airgap guard)
make validate-all

# Stage 2 alone
make validate-airgap

# Stages 5-6
make test

# Stage 8
make terraform-validate

# Stage 9
make ansible-lint
```
