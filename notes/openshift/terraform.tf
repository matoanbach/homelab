terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc06"
    }
  }

  required_version = ">= 1.0.0"
}

# -------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------

variable "install_dir" {
  description = "Directory where OCP installation files will be created"
  type        = string
  default     = "ocp-proxmox"
}

variable "proxmox_host" {
  description = "Proxmox host IP or DNS name for API calls"
  type        = string
  default     = "10.0.0.19"
}

variable "proxmox_api_token_id" {
  description = "API token ID for Proxmox API access. Format: user@realm!token-name"
  type        = string
  default     = "terraform@pve!terraform-token"
}

variable "proxmox_api_token_secret" {
  description = "API token secret for Proxmox API access"
  type        = string
  sensitive   = true
}

variable "iso_storage" {
  description = "Proxmox storage for ISO files"
  type        = string
  default     = "local"
}

variable "target_node" {
  description = "Proxmox node where VMs will be created"
  type        = string
  default     = "turtle"
}

variable "masters_cpu" {
  description = "CPU allocation for master nodes"
  type        = number
  default     = 6
}

variable "workers_cpu" {
  description = "CPU allocation for worker nodes"
  type        = number
  default     = 4
}

variable "masters_ram" {
  description = "RAM allocation for master nodes in MB"
  type        = number
  default     = 16384
}

variable "workers_ram" {
  description = "RAM allocation for worker nodes in MB"
  type        = number
  default     = 16384
}

variable "num_storages" {
  description = "Number of storages to alternate between when creating VMs"
  type        = number
  default     = 1
}

variable "vm_storage1" {
  description = "Primary storage for VM disks"
  type        = string
  default     = "local-lvm"
}

variable "vm_storage2" {
  description = "Secondary storage for VM disks"
  type        = string
  default     = "local-lvm"
}

variable "vm_maindisk_size" {
  description = "Main disk size for VMs"
  type        = string
  default     = "70G"
}

variable "vm_extradisk_size" {
  description = "Extra disk size for worker VMs"
  type        = string
  default     = "40G"
}

variable "bridge" {
  description = "Network bridge for VM interfaces"
  type        = string
  default     = "vmbr0"
}

variable "ssh_pubkey" {
  description = "SSH public key to inject into VM config"
  type        = string
  default     = ""
}

# -------------------------------------------------------------------
# Node definitions
# Must match agent-config.yaml MAC addresses
# -------------------------------------------------------------------

locals {
  nodes = [
    {
      name       = "ocp-master-1"
      role       = "master"
      mac        = "BC:24:11:44:22:32"
      vmid       = 101
      extra_disk = false
    },
    {
      name       = "ocp-master-2"
      role       = "master"
      mac        = "BC:24:11:44:22:35"
      vmid       = 102
      extra_disk = false
    },
    {
      name       = "ocp-master-3"
      role       = "master"
      mac        = "BC:24:11:44:22:36"
      vmid       = 103
      extra_disk = false
    },
  ]
}
# -------------------------------------------------------------------
# Check required tools are installed
# -------------------------------------------------------------------

resource "null_resource" "check_prerequisites" {
  provisioner "local-exec" {
    command = <<-EOT
      set -e

      MISSING_TOOLS=""

      if [ -x "./openshift-install" ]; then
        OPENSHIFT_INSTALL="./openshift-install"
      elif command -v openshift-install >/dev/null 2>&1; then
        OPENSHIFT_INSTALL="$(command -v openshift-install)"
      else
        MISSING_TOOLS="$MISSING_TOOLS openshift-install"
      fi

      if [ -x "./oc" ]; then
        OC="./oc"
      elif command -v oc >/dev/null 2>&1; then
        OC="$(command -v oc)"
      else
        MISSING_TOOLS="$MISSING_TOOLS oc"
      fi

      if ! command -v nmstatectl >/dev/null 2>&1; then
        MISSING_TOOLS="$MISSING_TOOLS nmstatectl"
      fi

      if ! command -v curl >/dev/null 2>&1; then
        MISSING_TOOLS="$MISSING_TOOLS curl"
      fi

      if [ -n "$MISSING_TOOLS" ]; then
        echo "ERROR: The following required tools are missing:$MISSING_TOOLS"
        echo ""
        echo "Install them before running Terraform:"
        echo "  - openshift-install"
        echo "  - oc"
        echo "  - nmstatectl"
        echo "  - curl"
        exit 1
      fi

      echo "All required tools are available."
      echo "openshift-install: $OPENSHIFT_INSTALL"
      echo "oc: $OC"
    EOT
  }
}

# -------------------------------------------------------------------
# Generate OCP Agent ISO
# -------------------------------------------------------------------

resource "null_resource" "generate_agent_iso" {
  depends_on = [null_resource.check_prerequisites]

  triggers = {
    install_config_hash = filemd5("${path.module}/install-config.yaml")
    agent_config_hash   = filemd5("${path.module}/agent-config.yaml")
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -e

      rm -rf ${var.install_dir}
      mkdir -p ${var.install_dir}

      cp ${path.module}/install-config.yaml ${var.install_dir}/
      cp ${path.module}/agent-config.yaml ${var.install_dir}/

      if [ -x "./openshift-install" ]; then
        ./openshift-install agent create image --dir=${var.install_dir}
      else
        openshift-install agent create image --dir=${var.install_dir}
      fi

      test -f ${var.install_dir}/agent.x86_64.iso
      echo "Agent ISO generated: ${var.install_dir}/agent.x86_64.iso"
    EOT
  }
}

# -------------------------------------------------------------------
# Upload ISO to Proxmox
# -------------------------------------------------------------------

resource "null_resource" "upload_iso_to_proxmox" {
  depends_on = [null_resource.generate_agent_iso]

  triggers = {
    iso_generated = null_resource.generate_agent_iso.id
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -e

      echo "Deleting existing Agent ISO if it exists..."
      curl -k -X DELETE \
        "https://${var.proxmox_host}:8006/api2/json/nodes/${var.target_node}/storage/${var.iso_storage}/content/${var.iso_storage}:iso/agent.x86_64.iso" \
        -H "Authorization: PVEAPIToken=${var.proxmox_api_token_id}=${var.proxmox_api_token_secret}" \
        || true

      echo "Uploading new Agent ISO to Proxmox..."
      curl -k -X POST \
        "https://${var.proxmox_host}:8006/api2/json/nodes/${var.target_node}/storage/${var.iso_storage}/upload" \
        -H "Authorization: PVEAPIToken=${var.proxmox_api_token_id}=${var.proxmox_api_token_secret}" \
        -F "content=iso" \
        -F "filename=@${var.install_dir}/agent.x86_64.iso"

      echo "Agent ISO uploaded."
    EOT
  }
}

# -------------------------------------------------------------------
# Proxmox Provider Configuration
# -------------------------------------------------------------------

provider "proxmox" {
  pm_api_url          = "https://${var.proxmox_host}:8006/api2/json"
  pm_api_token_id     = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret
  pm_tls_insecure     = true
  pm_parallel         = 1
}

# -------------------------------------------------------------------
# Create VMs
# -------------------------------------------------------------------

resource "proxmox_vm_qemu" "nodes" {
  for_each = { for idx, val in local.nodes : idx => val }

  depends_on = [null_resource.upload_iso_to_proxmox]

  name        = each.value.name
  vmid        = each.value.vmid
  target_node = var.target_node

  agent         = 1
  agent_timeout = 1
  skip_ipv6     = true

  cpu {
    cores   = each.value.role == "master" ? var.masters_cpu : var.workers_cpu
    sockets = 1
    type    = "host"
  }

  memory = each.value.role == "master" ? var.masters_ram : var.workers_ram

  # OpenShift nodes should not rely on memory ballooning.
  balloon = 0

  scsihw = "virtio-scsi-single"
  tags   = "ocp"

  boot = "order=scsi0;ide2"

  # Primary disk
  disk {
    slot       = "scsi0"
    size       = var.vm_maindisk_size
    type       = "disk"
    storage    = var.num_storages > 1 ? (tonumber(each.key) % 2 == 1 ? var.vm_storage1 : var.vm_storage2) : var.vm_storage1
    emulatessd = true
    discard    = true
    iothread   = true
  }

  # OpenShift Agent ISO
  disk {
    slot = "ide2"
    type = "cdrom"
    iso  = "${var.iso_storage}:iso/agent.x86_64.iso"
  }

  # Extra disk for workers
  dynamic "disk" {
    for_each = each.value.extra_disk ? [1] : []

    content {
      slot       = "scsi1"
      size       = var.vm_extradisk_size
      type       = "disk"
      storage    = var.num_storages > 1 ? (tonumber(each.key) % 2 == 1 ? var.vm_storage1 : var.vm_storage2) : var.vm_storage1
      emulatessd = true
      discard    = true
      iothread   = true
    }
  }

  network {
    id      = 0
    model   = "virtio"
    bridge  = var.bridge
    macaddr = each.value.mac
  }

  sshkeys = var.ssh_pubkey

  lifecycle {
    create_before_destroy = true
  }
}