# overview of the cluster
![K8s digram](https://github.com/matoanbach/homelab/blob/main/k8s/assets/k8s-the-hard-way/k8s-cluster.svg)

# Prerequisites (Proxmox + RHEL 10)

In this lab you will review the machine requirements necessary to follow this tutorial **on a single Proxmox host** using **RHEL 10** guest VMs.

## Virtual Machines (Proxmox)

This tutorial requires **four (4)** virtual machines (ARM64 or AMD64). On Proxmox, create **four KVM VMs** on the same bridge (e.g., `vmbr0`) with the following roles and minimum specs:

| Name    | Description            | vCPU | RAM   | Disk (GiB) | Notes |
|---------|------------------------|------|-------|------------|------|
| jumpbox | Administration host    | 2    | 4GB   | 20–30      | RHEL 10 installer is much smoother with ≥4GB RAM |
| server  | Kubernetes server      | 2    | 4GB   | 40         | Runs control plane + etcd in this topology |
| node-0  | Kubernetes worker node | 2    | 4GB   | 40–60      | Container images/logs consume disk |
| node-1  | Kubernetes worker node | 2    | 4GB   | 40–60      | Same as node-0 |

### Proxmox VM settings (recommended)

Use these settings to avoid common RHEL 10 boot/installer issues:

- **Machine:** `q35`
- **CPU type:** `host` (critical for RHEL 10; exposes required CPU features)
- **BIOS/Firmware:** OVMF (UEFI) preferred (SeaBIOS may work, but UEFI is smoother)
- **Disk bus:** SCSI
- **SCSI controller:** VirtIO SCSI single
- **Network model:** VirtIO
- **Bridge:** `vmbr0` (all VMs on the same bridge)
- **Firewall:** off during initial setup (enable later once stable)
- **Storage:** put VM disks on `local-lvm`; store ISOs on `local`

## OS Requirements

- Install **Red Hat Enterprise Linux 10** on each VM. Once provisioned, verify the OS version:

```bash
cat /etc/os-release

You should see output similar to:

NAME="Red Hat Enterprise Linux"
VERSION="10.0 (Coughlan)"
ID="rhel"
VERSION_ID="10.0"
PLATFORM_ID="platform:el10"
```

- Note: If you see early boot failures (e.g., “Attempted to kill init”), double-check the VM CPU type is set to host.

- Next: setting-up-the-jumpbox￼