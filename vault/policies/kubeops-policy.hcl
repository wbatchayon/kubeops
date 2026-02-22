# KubeOps Vault Policy

# Enable secrets engine
path "sys/mounts/*" {
  capabilities = ["create", "read", "update", "delete"]
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

# Kubernetes auth
path "auth/kubernetes/role/*" {
  capabilities = ["create", "read", "update", "delete"]
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
