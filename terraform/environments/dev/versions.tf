# Terraform and provider requirements for the dev environment

terraform {
  required_version = ">= 1.5"

  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "~> 2.9"
    }
  }

  backend "local" {
    path = "terraform.tfstate"
  }
}
