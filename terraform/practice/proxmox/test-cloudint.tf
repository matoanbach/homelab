resource "proxmox_vm_qemu" "cloudinit-example" {
  vmid        = 105
  name        = "test-terraform0"
  target_node = "pve"
  agent       = 1
  cores       = 2
  memory      = 2048
  boot        = "order=scsi0"
  clone       = "rhel-template"
  scsihw      = "virtio-scsi-single"
  vm_state    = "running"
  automatic_reboot = true

  # Cloud-Init configuration
  ciupgrade  = false
  nameserver = "1.1.1.1 8.8.8.8"
  ipconfig0  = "ip=10.0.0.24/24,gw=10.0.0.1"
  skip_ipv6  = true
  ciuser     = "toan"
  sshkeys    = file("~/.ssh/id_ed25519.pub")

  serial { id = 0 }

  disks {
    scsi {
      scsi0 {
        disk {
          storage = "local-lvm"
          size    = "20G"
        }
      }
    }
    ide {
      ide1 {
        cloudinit { storage = "local-lvm" }
      }
    }
  }

  network {
    id     = 0
    bridge = "vmbr0"
    model  = "virtio"
  }
}
