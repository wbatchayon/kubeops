# Terraform Configuration for KubeOps Cluster on Proxmox
# Version requirements are centralized in versions.tf

provider "proxmox" {
  # Connection will be provided via environment variables or tfvars
  # PM_API_URL, PM_USER, PM_PASSWORD or PM_API_TOKEN_ID, PM_API_TOKEN_SECRET
}

# Module: Network Configuration
module "network" {
  source = "../../modules/network"

  bridge       = var.network.bridge
  vlan_tag     = var.network.vlan_tag
  cluster_name = var.cluster.name
  environment  = var.environment
  tags         = var.tags
}

# Module: Compute (VMs)
module "compute" {
  source = "../../modules/compute"

  proxmox_node = var.proxmox.node

  cluster_name = var.cluster.name
  environment  = var.environment

  control_plane = var.control_plane
  worker        = var.worker

  network_bridge = var.network.bridge
  network_vlan   = var.network.vlan_tag
  ip_start       = var.network.ip_start
  ip_end         = var.network.ip_end
  gateway        = var.network.gateway
  dns_servers    = var.network.dns_servers

  ssh_user            = var.ssh.user
  ssh_password        = var.ssh.password
  ssh_authorized_keys = var.ssh.authorized_keys

  tags = var.tags
}

# Module: Storage
module "storage" {
  source = "../../modules/storage"

  cluster_name = var.cluster.name
  environment  = var.environment
  proxmox_node = var.proxmox.node
  tags         = var.tags
}

# Outputs
output "cluster_info" {
  description = "Cluster information"
  value = {
    name               = var.cluster.name
    environment        = var.environment
    kubernetes_version = var.cluster.kubernetes_version
    pod_cidr           = var.cluster.pod_cidr
    service_cidr       = var.cluster.service_cidr
  }
}

output "control_plane_ips" {
  description = "Control plane node IPs"
  value       = module.compute.control_plane_ips
}

output "worker_ips" {
  description = "Worker node IPs"
  value       = module.compute.worker_ips
}

output "ssh_config" {
  description = "SSH configuration for connecting to nodes"
  value       = <<-EOT
    # SSH Config for ${var.cluster.name} cluster (${var.environment})
    
    Host ${var.cluster.name}-cp-*
      User ${var.ssh.user}
      StrictHostKeyChecking accept-new
      UserKnownHostsFile ~/.ssh/known_hosts.kubeops

    Host ${var.cluster.name}-worker-*
      User ${var.ssh.user}
      StrictHostKeyChecking accept-new
      UserKnownHostsFile ~/.ssh/known_hosts.kubeops
  EOT
  sensitive   = true
}
