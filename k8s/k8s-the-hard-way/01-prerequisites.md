# overview of the cluster
![K8s diagram](https://github.com/matoanbach/homelab/blob/main/k8s/assets/k8s-the-hard-way/k8s-cluster.svg)
# Prerequisites (Proxmox + Ubuntu 24.04)

In this lab you will review the machine requirements necessary to follow this tutorial **on a single Proxmox host** using **Ubuntu 24.04 LTS** guest VMs.

## Virtual Machines (Proxmox)

This tutorial requires **four (4)** virtual machines (ARM64 or AMD64). On Proxmox, create **four KVM VMs** on the same bridge (e.g., `vmbr0`) with the following roles and minimum specs:

| Name    | Description            | vCPU | RAM   | Disk (GiB) | Notes |
|---------|------------------------|------|-------|------------|------|
| jumpbox | Administration host    | 2    | 2–4GB | 20–30      | Used to run kubectl, generate certs/kubeconfigs, and store downloads |
| server  | Kubernetes server      | 2    | 4GB   | 40         | Runs control plane + etcd in this topology |
| node-0  | Kubernetes worker node | 2    | 4GB   | 40–60      | Container images/logs consume disk |
| node-1  | Kubernetes worker node | 2    | 4GB   | 40–60      | Same as node-0 |

> Current IP plan (Ubuntu VMs): `10.0.0.22`–`10.0.0.25`  
> - jumpbox: `10.0.0.22`  
> - server: `10.0.0.23`  
> - node-0: `10.0.0.24`  
> - node-1: `10.0.0.25`

### Proxmox VM settings (recommended)

- **Machine:** `q35`
- **CPU type:** `host`
- **BIOS/Firmware:** OVMF (UEFI) preferred (SeaBIOS may also work)
- **Disk bus:** SCSI
- **SCSI controller:** VirtIO SCSI single
- **Network model:** VirtIO
- **Bridge:** `vmbr0` (all VMs on the same bridge)
- **Firewall:** off during initial setup (enable later once stable)
- **Storage:** put VM disks on `local-lvm`; store ISOs on `local`

## OS Requirements

Install **Ubuntu Server 24.04 LTS** on each VM. Once provisioned, verify the OS version:

```bash
cat /etc/os-release

You should see output similar to:

PRETTY_NAME="Ubuntu 24.04 LTS"
NAME="Ubuntu"
VERSION_ID="24.04"
VERSION="24.04 LTS (Noble Numbat)"
ID=ubuntu
```