terraform {
  required_version = ">= 0.14"
  required_providers {
    proxmox = {
      source  = "registry.example.com/telmate/proxmox"
      version = ">= 1.0.0" 
    }
  }
}

provider "proxmox" {
    pm_tls_insecure = true
    pm_api_url = ""
    pm_api_token_secret = ""
    pm_api_token_id = ""
}