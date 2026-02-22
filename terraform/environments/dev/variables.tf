# Terraform Variables for KubeOps Cluster

variable "proxmox" {
  description = "Proxmox connection configuration"
  type = object({
    url       = string
    user      = string
    password  = string
    token_id  = string
    token_secret = string
    node      = string
  })
  sensitive = true
}

variable "cluster" {
  description = "Kubernetes cluster configuration"
  type = object({
    name                = string
    kubernetes_version  = string
    pod_cidr            = string
    service_cidr        = string
    cluster_domain       = string
  })
  default = {
    name               = "kubeops"
    kubernetes_version = "v1.28.0"
    pod_cidr          = "10.244.0.0/16"
    service_cidr      = "10.96.0.0/16"
    cluster_domain    = "cluster.local"
  }
}

variable "control_plane" {
  description = "Control plane node configuration"
  type = object({
    replicas     = number
    cpu_cores    = number
    memory_mb    = number
    disk_size_gb = number
    network_model = string
  })
  default = {
    replicas     = 3
    cpu_cores    = 4
    memory_mb    = 8192
    disk_size_gb = 50
    network_model = "virtio"
  }
}

variable "worker" {
  description = "Worker node configuration"
  type = object({
    replicas     = number
    cpu_cores    = number
    memory_mb    = number
    disk_size_gb = number
    network_model = string
  })
  default = {
    replicas     = 3
    cpu_cores    = 4
    memory_mb    = 8192
    disk_size_gb = 50
    network_model = "virtio"
  }
}

variable "network" {
  description = "Network configuration"
  type = object({
    bridge     = string
    vlan_tag   = number
    ip_start   = string
    ip_end     = string
    gateway    = string
    dns_servers = list(string)
  })
  default = {
    bridge      = "vmbr0"
    vlan_tag   = 0
    ip_start   = "192.168.1.100"
    ip_end     = "192.168.1.200"
    gateway    = "192.168.1.1"
    dns_servers = ["1.1.1.1", "8.8.8.8"]
  }
}

variable "ssh" {
  description = "SSH configuration for nodes"
  type = object({
    authorized_keys = list(string)
    user            = string
    password        = string
  })
  sensitive = true
  default = {
    authorized_keys = []
    user            = "ubuntu"
    password        = ""
  }
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    project = "kubeops"
    managed_by = "terraform"
  }
}

# Output variables
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}
