# Compute Module - Proxmox VM Creation

terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "~> 2.9"
    }
  }
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
    replicas      = number
    cpu_cores     = number
    memory_mb     = number
    disk_size_gb  = number
    network_model = string
  })
}

variable "worker" {
  description = "Worker node configuration"
  type = object({
    replicas      = number
    cpu_cores     = number
    memory_mb     = number
    disk_size_gb  = number
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

# Static IP addressing scheme
# Must stay consistent with ansible/inventory/hosts.yaml:
#   control planes: ip_start .. ip_start+N-1   (e.g. 192.168.1.101-103)
#   workers:        ip_start+10 ..             (e.g. 192.168.1.111-113)
locals {
  ip_parts      = split(".", var.ip_start)
  ip_base       = join(".", slice(local.ip_parts, 0, 3))
  ip_start_host = tonumber(local.ip_parts[3])
  worker_offset = 10

  control_plane_ips = [
    for i in range(var.control_plane.replicas) :
    "${local.ip_base}.${local.ip_start_host + i}"
  ]
  worker_ips = [
    for i in range(var.worker.replicas) :
    "${local.ip_base}.${local.ip_start_host + local.worker_offset + i}"
  ]
}

# Control plane VMs
resource "proxmox_vm_qemu" "control_plane" {
  count = var.control_plane.replicas

  name        = "${var.cluster_name}-cp-${count.index + 1}"
  target_node = var.proxmox_node
  clone       = "ubuntu-jammy-cloudinit-template"

  cores  = var.control_plane.cpu_cores
  memory = var.control_plane.memory_mb
  disk {
    size    = "${var.control_plane.disk_size_gb}G"
    type    = "scsi"
    storage = "local-lvm"
  }

  network {
    model  = var.control_plane.network_model
    bridge = var.network_bridge
    tag    = var.network_vlan > 0 ? var.network_vlan : null
  }

  ciuser     = var.ssh_user
  cipassword = var.ssh_password != "" ? var.ssh_password : null
  sshkeys    = join("\n", var.ssh_authorized_keys)
  ipconfig0  = "ip=${local.control_plane_ips[count.index]}/24,gw=${var.gateway}"
  nameserver = join(" ", var.dns_servers)
  os_type    = "cloud-init"
  boot       = "order=scsi0"

  # telmate/proxmox expects tags as a semicolon-separated string
  # (Proxmox tags only allow [a-z0-9_.-], so map entries become key_value)
  tags = join(";", sort([
    for k, v in merge(var.tags, {
      role = "control-plane"
      node = "cp-${count.index + 1}"
    }) : "${k}_${v}"
  ]))
}

# Worker VMs
resource "proxmox_vm_qemu" "worker" {
  count = var.worker.replicas

  name        = "${var.cluster_name}-worker-${count.index + 1}"
  target_node = var.proxmox_node
  clone       = "ubuntu-jammy-cloudinit-template"

  cores  = var.worker.cpu_cores
  memory = var.worker.memory_mb
  disk {
    size    = "${var.worker.disk_size_gb}G"
    type    = "scsi"
    storage = "local-lvm"
  }

  network {
    model  = var.worker.network_model
    bridge = var.network_bridge
    tag    = var.network_vlan > 0 ? var.network_vlan : null
  }

  ciuser     = var.ssh_user
  cipassword = var.ssh_password != "" ? var.ssh_password : null
  sshkeys    = join("\n", var.ssh_authorized_keys)
  ipconfig0  = "ip=${local.worker_ips[count.index]}/24,gw=${var.gateway}"
  nameserver = join(" ", var.dns_servers)
  os_type    = "cloud-init"
  boot       = "order=scsi0"

  tags = join(";", sort([
    for k, v in merge(var.tags, {
      role = "worker"
      node = "worker-${count.index + 1}"
    }) : "${k}_${v}"
  ]))
}

output "control_plane_ips" {
  description = "Control plane node IP addresses"
  value       = proxmox_vm_qemu.control_plane[*].default_ipv4_address
}

output "worker_ips" {
  description = "Worker node IP addresses"
  value       = proxmox_vm_qemu.worker[*].default_ipv4_address
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
  value       = concat(proxmox_vm_qemu.control_plane[*].default_ipv4_address, proxmox_vm_qemu.worker[*].default_ipv4_address)
}
