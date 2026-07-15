# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- End-to-end deployment guide (docs/deployment.md): Terraform → Ansible →
  Cilium → Argo CD handover, out-of-band secrets, verification steps

### Fixed

- configuration.md now matches the code: correct top-level CLI config
  keys, real Terraform variable names (via terraform.tfvars.example), and
  the Ansible inventory variables that matter
- README quick start and the CLI reference no longer present the
  scaffolding CLI as functional; they point to the deployment guide

## [0.1.0] - 2026-07-15

### Added

- Terraform modules for Proxmox VM provisioning (compute, network, storage)
- Ansible playbooks and roles for kubeadm-based cluster bootstrap
- Cluster API manifests for Proxmox (KubeadmControlPlane, MachineDeployment)
- Argo CD app-of-apps GitOps layout (Cilium, kube-prometheus-stack, Gateway API)
- `kubeops` CLI (init, deploy, destroy, status, validate, secrets, app)
- CI pipeline (lint, build, test, security scan, packaging)
- Community health files (LICENSE, CONTRIBUTING, CODE_OF_CONDUCT, SECURITY)
- Harbor private registry (Argo CD app) used as pull-through proxy cache
  for every upstream registry and as OCI Helm chart repository
- cert-manager (Argo CD app, Gateway API support) with the internal
  `kubeops-ca` ClusterIssuer
- Node firewall role (nftables, default drop: only 443 admitted from
  outside the cluster/admin networks)
- containerd registry mirrors through Harbor and internal CA trust
  distribution on the nodes
- Air-gapped deployment guide (docs/airgap.md)
- CI airgap guard (`scripts/airgap-guard.sh`, also `make validate-airgap`):
  fails when an external Argo CD source, a plain HTTP listener, or an ACME
  issuer is reintroduced
- CI Helm/manifest validation: `helm lint`, vendor charts rendered against
  the committed values, kubeconform on the raw manifests
- Issue template chooser config: blank issues disabled, security reports
  routed to private advisories, questions to Discussions
- Release automation: GoReleaser (multi-platform binaries, sha256
  checksums) driven by a tag-triggered workflow that also publishes the
  container image to ghcr.io and the base Helm chart as OCI

### Changed

- Secrets management standardized on OpenBao (the Linux Foundation fork of
  HashiCorp Vault, MPL-2.0) so the whole stack remains open source
- Argo CD chart sources moved from public repositories to Harbor
  (`harbor.kubeops.local/charts`) for air-gapped operation
- Kubernetes package repository and containerd download URLs are now
  Ansible variables, so they can point at internal mirrors
- Gateway certificates issued by the internal PKI (`kubeops-ca`) instead
  of Let's Encrypt (ACME is unreachable in airgap)
- Initial design document (plans/architecture.md) folded into
  docs/architecture.md; plans/ now only carries the roadmap

### Security

- Grafana admin credentials sourced from a Secret instead of chart defaults
- Argo CD upgraded to a patched release, API/UI no longer exposed via LoadBalancer
- App-of-apps no longer auto-prunes child applications
- Workload base chart defaults to non-root, read-only root filesystem
- Cilium WireGuard encryption enabled; agent capabilities reduced to upstream defaults
- OpenBao policy scoped (no engine mounts, restricted Kubernetes auth roles)
- kubeadm join tokens and certificate keys excluded from Ansible logs (no_log)
- SSH host-key verification enabled (accept-new with pinned known_hosts)
- CI: least-privilege workflow token, third-party action pinned to commit SHA
- main branch protected: PR-only merges gated on a code-owner review,
  green CI (airgap guard included), and linear history (squash only)
- containerd systemd unit vendored instead of downloaded at run time
- .gitignore hardened (tfvars, SSH private keys, OpenBao tokens)
- Gateway exposes HTTPS (443) only — the HTTP listener was removed
  entirely, and Cilium hostPort is disabled

### Fixed

- Hardened CI workflow (valid steps, pinned actions, real yamllint/gofmt gates)
- Kubernetes apt repository moved to pkgs.k8s.io (legacy Google repo is dead)
- kubeadm HA flow: init on first control plane only, others join
- containerd config.toml syntax and restart-on-change handler
- Argo CD root application project/repo wiring
