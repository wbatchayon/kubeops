# KubeOps Roadmap

Priorities for taking the project from a reviewed codebase to a running,
maintainable platform. Phases are ordered; items within a phase are roughly
ordered by dependency.

## Phase 1 — Make the stack deployable end to end

The blockers that prevent a first successful deployment today.

- [ ] **Resolve `${...}` placeholders in GitOps values.** Argo CD does not
  substitute environment variables: `cilium/base/values.yaml`
  (`${CLUSTER_NAME}`, `${POD_CIDR}`) and the `cluster-api/bases/*.yaml`
  manifests need either real committed values per environment or a
  render step (kustomize overlays or `clusterctl generate --from`).
- [ ] **Create the out-of-band secrets** and document them in the runbook:
  `grafana-admin` (monitoring), `harbor-admin` (harbor),
  `kubeops-ca-root` (cert-manager, from the OpenBao PKI intermediate) and
  `${CLUSTER_NAME}-proxmox-credentials` (Cluster API).
- [ ] **Add a control-plane VIP.** The kubeadm HA flow currently uses the
  first control plane's address as `controlPlaneEndpoint`, which is a
  single point of failure. Deploy kube-vip (static pod) or an external
  HAProxy, then set `control_plane_endpoint` in the kubeadm role defaults.
- [ ] **Seed Harbor and validate the airgap path.** The manifests exist
  (`harbor/`, containerd mirrors, `docs/airgap.md`); run the seeding
  procedure end to end: proxy-cache projects, chart pushes, bootstrap
  image preload, package mirror.
- [ ] **Clarify the provisioning story.** Terraform+Ansible and Cluster API
  currently overlap. Recommended split: Terraform+Ansible bootstraps the
  management cluster; Cluster API (CAPMOX) manages workload clusters from
  it. Document the decision in docs/architecture.md.
- [ ] **Write the end-to-end runbook**: Proxmox template creation →
  `terraform apply` → `ansible-playbook bootstrap` → Argo CD install →
  root app apply, with verification steps at each stage.

## Phase 2 — Implement the CLI

The `kubeops` commands are scaffolding (they print what they would do).

- [ ] `kubeops validate` — shell out to `terraform validate`, `yamllint`,
  `ansible-playbook --syntax-check` (mirrors `make validate-all`).
- [ ] `kubeops init` — generate `terraform.tfvars` and the Ansible
  inventory from the flags (single source of truth for IPs/replicas).
- [ ] `kubeops deploy` — orchestrate terraform → ansible → Argo CD
  bootstrap with `--skip-*` and `--dry-run` honored.
- [ ] `kubeops status` — read cluster state via client-go (nodes, Argo CD
  app health); implement `--json-output` and `--watch`.
- [ ] Integration tests under `test/integration` (build-tagged), then
  remove the CI/Makefile skip guards.
- [ ] Self-hosted runner inside the perimeter for the Deploy Test and
  Monitoring stages: GitHub-hosted runners cannot reach an air-gapped
  cluster.
- [x] Release automation: goreleaser config + tag-triggered release
  workflow with checksums, GHCR image, and OCI Helm chart. Remaining:
  optionally publish a Homebrew tap once releases exist.

## Phase 3 — Platform features

- [ ] **OpenBao deployment.** The policy exists (`openbao/policies/`) but
  OpenBao itself is not installed. Add an Argo CD child app (official
  `openbao` chart), initialization runbook (including the PKI engine that
  backs the `kubeops-ca` issuer), and External Secrets Operator to consume
  it (replaces the manual `grafana-admin` secret from Phase 1).
- [ ] **Internal git mirror.** The Argo CD applications still pull from
  GitHub; a fully air-gapped cluster needs an in-perimeter git server
  (e.g. Gitea) as the GitOps source of truth.
- [ ] **Alerting.** Alertmanager routes/receivers (email or webhook) and a
  starter set of PrometheusRules; Grafana dashboards provisioned from git
  (the dashboard provider is already configured).
- [ ] **Backups.** etcd snapshot CronJob on control planes; Velero with a
  Proxmox-reachable object store for workload backup.
- [ ] **Network policies.** Default-deny CiliumNetworkPolicies per
  namespace with explicit allows; Hubble UI behind an authenticated
  Gateway route.
- [ ] **Dependency automation.** Renovate (or Dependabot) for Helm chart
  versions, GitHub Actions, Go modules, and the pinned containerd/
  Kubernetes versions in Ansible defaults.
- [ ] **Upgrades.** Documented and tested upgrade path: Kubernetes minor
  versions via kubeadm (and later CAPI rolling upgrades), Cilium and
  chart bumps through Argo CD.

## Phase 4 — Open-source maturity

- [ ] First tagged release (v0.1.0) once Phase 1 completes; keep
  CHANGELOG.md per release.
- [ ] Make ansible-lint blocking in CI (fix remaining warnings first) and
  add a golangci-lint config; consider a Trivy severity gate.
- [ ] Label a set of good-first-issues; add a development-environment
  section to CONTRIBUTING.md (kind/k3d for manifest testing without
  Proxmox).
- [ ] Documentation site (mkdocs-material) published via GitHub Pages.
- [ ] Architecture decision records (docs/adr/) for the choices already
  made: telmate vs bpg provider, kubeadm vs CAPI bootstrap, Cilium
  Gateway API vs ingress.
