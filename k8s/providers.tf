terraform {
  required_providers {
    # proxmox = {
    #   source  = "bpg/proxmox"
    # }
    # talos = {
    #   source = "siderolabs/talos"
    #   version = "0.5.0"
    # }
    local = {
      source  = "hashicorp/local"
      version = "~>2.2"
    }
  }
}

# provider "proxmox" {
#   endpoint = "https://${var.PROXMOX_HOST}:8006/"
#   username = var.PROXMOX_USERNAME
#   password = var.PROXMOX_PASSWORD
#   insecure = true
# }
