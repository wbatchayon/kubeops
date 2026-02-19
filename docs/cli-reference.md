# CLI Reference

Complete reference for KubeOps CLI commands.

## Global Options

```bash
kubeops [global options] <command> [command options]
```

| Option | Description |
|--------|-------------|
| `--config, -c` | Configuration file path |
| `--environment` | Environment (dev/staging/prod) |
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
| `--name` | Cluster name |
| `--kubernetes-version` | Kubernetes version (default: v1.28.0) |
| `--control-plane-replicas` | Number of control plane nodes (default: 3) |
| `--worker-replicas` | Number of worker nodes (default: 3) |

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
| `--skip-validation` | Skip pre-deployment validation |
| `--terraform-only` | Only run Terraform |
| `--ansible-only` | Only run Ansible |

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
| `--force` | Force destruction without confirmation |
| `--preserve-storage` | Preserve storage volumes |

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
| `--output json` | Output in JSON format |

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

**Example:**
```bash
kubeops validate
```

---

### app

Manage applications.

```bash
kubeapp <subcommand>
```

#### app deploy

Deploy an application.

```bash
kubeops app deploy <name> <chart-path> [options]
```

**Options:**
| Option | Description |
|--------|-------------|
| `--values` | Values file path |
| `--namespace` | Target namespace |

**Example:**
```bash
kubeops app deploy myapp ./helm-chart --values values.yaml
```

#### app list

List deployed applications.

```bash
kubeops app list
```

#### app delete

Delete an application.

```bash
kubeops app delete <name>
```

---

### secrets

Manage secrets with Vault.

```bash
kubeops secrets <subcommand>
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

#### secrets delete

Delete a secret.

```bash
kubeops secrets delete <key>
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
| 1 | General error |
| 2 | Validation error |
| 3 | Cluster not found |
| 4 | Deployment failed |
| 5 | Authentication error |
