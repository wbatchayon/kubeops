# Network Module - Proxmox Network Configuration
# This module creates no resources (Proxmox network configuration via
# Terraform is limited), so it declares no provider requirements.

variable "bridge" {
  description = "Bridge interface"
  type        = string
}

variable "vlan_tag" {
  description = "VLAN tag"
  type        = number
  default     = 0
}

variable "cluster_name" {
  description = "Cluster name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}

# Note: Proxmox network configuration via Terraform is limited
# This module provides outputs and documentation for network setup

output "bridge_name" {
  description = "Bridge interface name"
  value       = var.bridge
}

output "vlan_id" {
  description = "VLAN ID"
  value       = var.vlan_tag
}

output "network_info" {
  description = "Network configuration info"
  value = {
    bridge      = var.bridge
    vlan_tag    = var.vlan_tag
    cluster     = var.cluster_name
    environment = var.environment
  }
}
