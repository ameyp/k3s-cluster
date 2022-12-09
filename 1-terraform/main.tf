terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = "~> 2.9.11"
    }
  }
}

provider "proxmox" {
  pm_api_url = var.proxmox.api_url
  pm_api_token_id = var.proxmox.token_id
  pm_api_token_secret = var.proxmox.token_secret
  pm_tls_insecure = true
  # This doesn't seem to do anything
  # To actually debug, export TF_LOG=TRACE
  pm_debug = true
}

terraform {
  backend "local" {
  }
}
