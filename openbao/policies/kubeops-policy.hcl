# KubeOps OpenBao Policy

# List secrets engines (read-only; mounting engines is an operator task,
# not something this policy should allow)
path "sys/mounts" {
  capabilities = ["read"]
}

# Kubernetes secrets
path "secret/data/kubeops/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "secret/metadata/kubeops/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Certificates
path "pki_int/issue/kubeops/*" {
  capabilities = ["create", "read", "update"]
}

path "pki_int/certs" {
  capabilities = ["read", "list"]
}

# Kubernetes auth: only roles owned by this project, and no delete
# (creating a role bound to a privileged ServiceAccount is an escalation path)
path "auth/kubernetes/role/kubeops-*" {
  capabilities = ["create", "read", "update"]
}

# Transit secrets engine for encryption
path "transit/keys/kubeops" {
  capabilities = ["create", "read", "update"]
}

path "transit/encrypt/kubeops" {
  capabilities = ["create", "update"]
}

path "transit/decrypt/kubeops" {
  capabilities = ["create", "update"]
}
