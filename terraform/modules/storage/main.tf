# Storage Module - Proxmox Storage Configuration

terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
    }
  }
}

variable "cluster_name" {
  description = "Cluster name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "proxmox_node" {
  description = "Proxmox node name"
  type        = string
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}

# Storage configuration outputs
# Note: Most Proxmox storage is configured at the node/cluster level
# This module documents the storage requirements

output "storage_info" {
  description = "Storage configuration info"
  value = {
    cluster_name  = var.cluster_name
    environment   = var.environment
    node         = var.proxmox_node
    recommended_storages = {
      local      = "Local storage for VM templates"
      local_lvm = "Local LVM storage for VM disks"
      shared     = "Shared storage (Ceph/NFS) for persistent volumes"
    }
  }
}

output "volume_requirements" {
  description = "Volume requirements for the cluster"
  value = {
    control_plane_disk = "50GB per control plane node"
    worker_disk       = "50GB per worker node (expandable)"
    etcd_volume       = "20GB for etcd (embedded in control plane disk)"
    containerd_volume = "Containerd uses control plane disk"
  }
}
