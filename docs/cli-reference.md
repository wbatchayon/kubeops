# CLI Reference

Complete reference for KubeOps CLI commands.

> **Status (v0.1.x):** the commands below are scaffolding — they parse
> flags and print the actions they will perform, but do not execute them
> yet (implementation tracked in the
> [roadmap](../plans/ROADMAP.md), Phase 2). To deploy a cluster today,
> follow the [deployment guide](deployment.md).

## Global Options

```bash
kubeops [global options] <command> [command options]
```

| Option | Description |
|--------|-------------|
| `--config, -c` | Configuration file path |
| `--environment` | Environment (dev/prod) |
| `--verbose, -v` | Enable verbose output |
| `--version` | Show version information |
| `--help, -h` | Show help |

## Commands

### init

Initialize a new Kubernetes cluster configuration.

```bash
kubeops init [command options]
```

**Options:**
| Option | Description |
|--------|-------------|
| `--name` | Cluster name (default: kubeops) |
| `--kubernetes-version` | Kubernetes version (default: v1.28.0) |
| `--control-plane-nodes` | Number of control plane nodes (default: 3) |
| `--worker-nodes` | Number of worker nodes (default: 3) |

**Example:**
```bash
kubeops init --name mycluster --kubernetes-version v1.28.0
```

---

### deploy

Deploy the Kubernetes cluster.

```bash
kubeops deploy [command options]
```

**Options:**
| Option | Description |
|--------|-------------|
| `--skip-terraform` | Skip Terraform provisioning |
| `--skip-ansible` | Skip Ansible configuration |
| `--skip-capi` | Skip Cluster API deployment |
| `--dry-run` | Dry run mode |

**Example:**
```bash
kubeops deploy
```

---

### destroy

Destroy the Kubernetes cluster.

```bash
kubeops destroy [command options]
```

**Options:**
| Option | Description |
|--------|-------------|
| `--force, -f` | Force destruction without confirmation |

Without `--force`, the command refuses to run and exits with a non-zero code.

**Example:**
```bash
kubeops destroy --force
```

---

### status

Show cluster status.

```bash
kubeops status [command options]
```

**Options:**
| Option | Description |
|--------|-------------|
| `--json-output` | Output in JSON format |
| `--watch` | Watch status continuously |

**Example:**
```bash
kubeops status
```

---

### validate

Validate cluster configuration.

```bash
kubeops validate [command options]
```

**Options:**
| Option | Description |
|--------|-------------|
| `--all` | Validate all components |
| `--terraform` | Validate Terraform only |
| `--ansible` | Validate Ansible only |
| `--kubernetes` | Validate Kubernetes manifests only |

With no option, everything is validated.

**Example:**
```bash
kubeops validate --terraform
```

---

### app

Manage applications.

```bash
kubeops app <subcommand>
```

#### app deploy

Deploy an application.

```bash
kubeops app deploy [chart]
```

**Example:**
```bash
kubeops app deploy ./helm-chart
```

#### app list

List deployed applications.

```bash
kubeops app list
```

#### app sync

Sync an application (Argo CD).

```bash
kubeops app sync [app]
```

---

### secrets

Manage secrets with OpenBao.

```bash
kubeops secrets <subcommand>
```

#### secrets init

Initialize OpenBao.

```bash
kubeops secrets init
```

#### secrets set

Set a secret.

```bash
kubeops secrets set <key> <value>
```

**Example:**
```bash
kubeops secrets set db/password "mypassword"
```

#### secrets get

Get a secret.

```bash
kubeops secrets get <key>
```

---

### completion

Generate completion script.

```bash
kubeops completion <shell>
```

**Supported shells:** bash, zsh, fish, powershell

**Example:**
```bash
# Bash
source <(kubeops completion bash)

# Zsh
source <(kubeops completion zsh)
```

---

### version

Show version information.

```bash
kubeops version
```

---

## Exit Codes

| Code | Description |
|------|-------------|
| 0 | Success |
| 1 | Error (validation, deployment, refused destroy, etc.) |
