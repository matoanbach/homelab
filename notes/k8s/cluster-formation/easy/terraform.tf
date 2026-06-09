terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc06"
    }
  }
  required_version = ">= 1.0.0"
}

# VARIABLES

variable "proxmox_host" {
  type    = string
  default = "10.0.0.19"
}

variable "proxmox_api_token_id" {
  type    = string
  default = "terraform@pve!terraform-token"
}

variable "proxmox_api_token_secret" {
  type      = string
  sensitive = true
}

variable "target_node" {
  type    = string
  default = "turtle"
}

variable "template_name" {
  description = "Name of the Proxmox cloud-init template to clone"
  type        = string
  default     = "ubuntu-2404-cloudinit-template"
}

variable "vm_storage" {
  type    = string
  default = "local-lvm"
}

variable "bridge" {
  type    = string
  default = "vmbr0"
}

variable "gateway" {
  type    = string
  default = "10.0.0.1"
}

variable "ssh_user" {
  type    = string
  default = "ubuntu"
}

variable "ssh_pubkey" {
  type = string
}
variable "dns_server" {
  type    = string
  default = "10.0.0.1"
}

variable "search_domain" {
  type    = string
  default = "local"
}

locals {
  nodes = {
    "k8s-cp1" = {
      vmid   = 201
      ip     = "10.0.0.101"
      cores  = 2
      memory = 8192
      disk   = "40G"
      role   = "control"
    }

    "k8s-w1" = {
      vmid   = 202
      ip     = "10.0.0.102"
      cores  = 2
      memory = 8192
      disk   = "40G"
      role   = "worker"
    }

    "k8s-w2" = {
      vmid   = 203
      ip     = "10.0.0.103"
      cores  = 2
      memory = 8192
      disk   = "40G"
      role   = "worker"
    }
  }
}


provider "proxmox" {
  pm_api_url          = "https://${var.proxmox_host}:8006/api2/json"
  pm_api_token_id     = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret
  pm_tls_insecure     = true
  pm_parallel         = 5
}

resource "proxmox_vm_qemu" "k8s_nodes" {
  for_each = local.nodes

  name        = each.key
  vmid        = each.value.vmid
  target_node = var.target_node

  clone      = var.template_name
  full_clone = true

  qemu_os = "l26"
  os_type = "cloud-init"

  agent         = 1
  agent_timeout = 180
  skip_ipv6     = true

  vm_state = "running"
  #onboot = true

  boot = "order=scsi0"

  cpu {
    cores   = each.value.cores
    sockets = 1
    type    = "host"
  }

  memory = each.value.memory
  scsihw = "virtio-scsi-single"
  tags   = "kubespray;k8s"

  serial {
    id   = 0
    type = "socket"
  }

  disks {
    scsi {
      scsi0 {
        disk {
          size       = each.value.disk
          storage    = var.vm_storage
          iothread   = true
          discard    = true
          emulatessd = true
        }
      }
    }
    ide {
      ide0 {
        cloudinit {
          storage = var.vm_storage
        }
      }
    }
  }

  network {
    id     = 0
    model  = "virtio"
    bridge = var.bridge
  }

  ipconfig0 = "ip=${each.value.ip}/24,gw=${var.gateway}"

  ciuser       = var.ssh_user
  ssh_user     = var.ssh_user
  sshkeys      = var.ssh_pubkey
  nameserver   = var.dns_server
  searchdomain = var.search_domain

  lifecycle { ignore_changes = [network, ] }
}

resource "local_file" "kubespray_inventory" {
  filename = "${path.module}/inventory.ini"

  content = templatefile("${path.module}/inventory.ini.tftpl", {
    nodes    = local.nodes
    ssh_user = var.ssh_user
  })
}
