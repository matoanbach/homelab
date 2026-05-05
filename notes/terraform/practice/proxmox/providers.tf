terraform {
  required_version = ">=1.3.3"

  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc04"
    }
  }
}

provider "proxmox" {
  pm_api_url          = "https://10.0.0.19:8006/api2/json"
  pm_api_token_id     = "root@pam!terraform"
  pm_api_token_secret = "4e558154-300b-41ef-90e5-e80b96932aa3" 
  pm_tls_insecure     = true
}

