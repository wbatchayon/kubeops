# Compute Module - Proxmox VM Creation

terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
    }
  }
}

variable "proxmox_url" {
  description = "Proxmox API URL"
  type        = string
}

variable "proxmox_user" {
  description = "Proxmox user"
  type        = string
}

variable "proxmox_token_id" {
  description = "Proxmox API token ID"
  type        = string
  default     = ""
}

variable "proxmox_token_secret" {
  description = "Proxmox API token secret"
  type        = string
  default     = ""
  sensitive   = true
}

variable "proxmox_node" {
  description = "Proxmox node name"
  type        = string
}

variable "cluster_name" {
  description = "Cluster name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "control_plane" {
  description = "Control plane configuration"
  type = object({
    replicas     = number
    cpu_cores    = number
    memory_mb    = number
    disk_size_gb = number
    network_model = string
  })
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
}

variable "network_bridge" {
  description = "Network bridge"
  type        = string
}

variable "network_vlan" {
  description = "Network VLAN tag"
  type        = number
  default     = 0
}

variable "ip_start" {
  description = "IP range start"
  type        = string
}

variable "ip_end" {
  description = "IP range end"
  type        = string
}

variable "gateway" {
  description = "Gateway IP"
  type        = string
}

variable "dns_servers" {
  description = "DNS servers"
  type        = list(string)
  default     = ["1.1.1.1", "8.8.8.8"]
}

variable "ssh_user" {
  description = "SSH user"
  type        = string
}

variable "ssh_password" {
  description = "SSH password"
  type        = string
  sensitive   = true
}

variable "ssh_authorized_keys" {
  description = "SSH authorized keys"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}

# Cloud-init user data template (using templatefile function)
locals {
  cloud_init_user_data = templatefile("${path.module}/templates/cloud-init-user-data.yaml.tpl", {
    hostname              = "kubeops-node"
    ssh_user             = var.ssh_user
    ssh_authorized_keys = var.ssh_authorized_keys
  })
}

# Control plane VMs
resource "proxmox_vm_qemu" "control_plane" {
  count = var.control_plane.replicas

  name        = "${var.cluster_name}-cp-${count.index + 1}"
  target_node = var.proxmox_node
  clone       = "ubuntu-jammy-cloudinit-template"

  cores    = var.control_plane.cpu_cores
  memory   = var.control_plane.memory_mb
  disk {
    size    = "${var.control_plane.disk_size_gb}G"
    type    = "scsi"
    storage = "local-lvm"
  }

  network {
    model  = var.control_plane.network_model
    bridge = var.network_bridge
  }

  ciuser         = var.ssh_user
  cipassword     = var.ssh_password
  sshkeys        = join("\n", var.ssh_authorized_keys)
  os_type        = "cloud-init"
  boot           = "order=scsi0"

  tags = merge(var.tags, {
    role = "control-plane"
    node = "cp-${count.index + 1}"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Worker VMs
resource "proxmox_vm_qemu" "worker" {
  count = var.worker.replicas

  name        = "${var.cluster_name}-worker-${count.index + 1}"
  target_node = var.proxmox_node
  clone       = "ubuntu-jammy-cloudinit-template"

  cores    = var.worker.cpu_cores
  memory   = var.worker.memory_mb
  disk {
    size    = "${var.worker.disk_size_gb}G"
    type    = "scsi"
    storage = "local-lvm"
  }

  network {
    model  = var.worker.network_model
    bridge = var.network_bridge
  }

  ciuser         = var.ssh_user
  cipassword     = var.ssh_password
  sshkeys        = join("\n", var.ssh_authorized_keys)
  os_type        = "cloud-init"
  boot           = "order=scsi0"

  tags = merge(var.tags, {
    role = "worker"
    node = "worker-${count.index + 1}"
  })

  lifecycle {
    create_before_destroy = true
  }
}

output "control_plane_ips" {
  description = "Control plane node IP addresses"
  value       = proxmox_vm_qemu.control_plane[*].ip_address
}

output "worker_ips" {
  description = "Worker node IP addresses"
  value       = proxmox_vm_qemu.worker[*].ip_address
}

output "control_plane_ids" {
  description = "Control plane VM IDs"
  value       = proxmox_vm_qemu.control_plane[*].vmid
}

output "worker_ids" {
  description = "Worker VM IDs"
  value       = proxmox_vm_qemu.worker[*].vmid
}

output "all_ips" {
  description = "All node IP addresses"
  value       = concat(proxmox_vm_qemu.control_plane[*].ip_address, proxmox_vm_qemu.worker[*].ip_address)
}
