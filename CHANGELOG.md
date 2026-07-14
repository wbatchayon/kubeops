# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Terraform modules for Proxmox VM provisioning (compute, network, storage)
- Ansible playbooks and roles for kubeadm-based cluster bootstrap
- Cluster API manifests for Proxmox (KubeadmControlPlane, MachineDeployment)
- Argo CD app-of-apps GitOps layout (Cilium, kube-prometheus-stack, Gateway API)
- `kubeops` CLI (init, deploy, destroy, status, validate, secrets, app)
- CI pipeline (lint, build, test, security scan, packaging)
- Community health files (LICENSE, CONTRIBUTING, CODE_OF_CONDUCT, SECURITY)

### Security

- Grafana admin credentials sourced from a Secret instead of chart defaults
- Argo CD upgraded to a patched release, API/UI no longer exposed via LoadBalancer
- App-of-apps no longer auto-prunes child applications
- Workload base chart defaults to non-root, read-only root filesystem
- Cilium WireGuard encryption enabled; agent capabilities reduced to upstream defaults
- Vault policy scoped (no engine mounts, restricted Kubernetes auth roles)
- kubeadm join tokens and certificate keys excluded from Ansible logs (no_log)
- SSH host-key verification enabled (accept-new with pinned known_hosts)
- CI: least-privilege workflow token, third-party action pinned to commit SHA
- containerd systemd unit vendored instead of downloaded at run time
- .gitignore hardened (tfvars, SSH private keys, Vault tokens)
- HTTP traffic on the Gateway redirected to HTTPS

### Fixed

- Hardened CI workflow (valid steps, pinned actions, real yamllint/gofmt gates)
- Kubernetes apt repository moved to pkgs.k8s.io (legacy Google repo is dead)
- kubeadm HA flow: init on first control plane only, others join
- containerd config.toml syntax and restart-on-change handler
- Argo CD root application project/repo wiring
