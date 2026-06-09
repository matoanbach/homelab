# Create an Ubuntu Cloud-Init Template for Proxmox

This guide explains how to create an Ubuntu 24.04 cloud-init template in Proxmox so Terraform can clone VMs for Kubespray.

## Why the ISO is not enough

The Ubuntu ISO you already have, for example:

```text
ubuntu-24.04.3-live-server-amd64.iso
```

is a normal installer ISO. It is useful when you want to manually install Ubuntu into a VM.

For Terraform + Kubespray, we want something different: a ready-to-clone VM template.

Kubespray expects normal Linux machines that are already running and reachable over SSH. It does not boot from an installer ISO. That means each VM needs:

```text
Ubuntu/Debian installed
SSH server available
Python available
Network/IP configured
Your SSH public key installed
```

The easiest way to create those VMs repeatedly is to use an Ubuntu cloud image and Proxmox cloud-init.

## Recommended approach

Use the Ubuntu cloud image:

```text
noble-server-cloudimg-amd64.img
```

This image is already cloud-init-ready. Proxmox can use cloud-init to inject:

```text
hostname
SSH public key
username
static IP
gateway
DNS
```

Then Terraform can clone the template into Kubernetes nodes like:

```text
k8s-cp1
k8s-w1
k8s-w2
```

## Target template name

This guide creates a Proxmox template named:

```text
ubuntu-2404-cloudinit-template
```

Your Terraform should use the same name:

```hcl
template_name = "ubuntu-2404-cloudinit-template"
```

## Step 1: SSH into the Proxmox host

Run these commands on the Proxmox host as `root`.

```bash
ssh root@10.0.0.19
```

## Step 2: Download the Ubuntu cloud image

```bash
cd /var/lib/vz/template/iso
wget https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img
```

## Step 3: Install tools for customizing the image

```bash
apt update
apt install -y libguestfs-tools
```

## Step 4: Install QEMU guest agent into the image

The QEMU guest agent helps Proxmox and Terraform detect VM status and IP information.

```bash
virt-customize -a noble-server-cloudimg-amd64.img --install qemu-guest-agent
```

## Step 5: Create a new VM shell

Use a high VM ID that will not conflict with normal VMs. This example uses `9000`.

```bash
qm create 9000 \
  --name ubuntu-2404-cloudinit-template \
  --memory 2048 \
  --cores 2 \
  --net0 virtio,bridge=vmbr0 \
  --scsihw virtio-scsi-single
```

## Step 6: Import the cloud image disk into Proxmox storage

This example uses `local-lvm`, which is usually the right storage for VM disks.

```bash
qm importdisk 9000 noble-server-cloudimg-amd64.img local-lvm
```

## Step 7: Attach the imported disk to the VM

```bash
qm set 9000 --scsi0 local-lvm:vm-9000-disk-0
```

## Step 8: Add a cloud-init drive

This lets Proxmox pass cloud-init data to cloned VMs.

```bash
qm set 9000 --ide2 local-lvm:cloudinit
```

## Step 9: Set the VM boot disk

```bash
qm set 9000 --boot c --bootdisk scsi0
```

## Step 10: Enable serial console

Cloud images commonly use serial console output.

```bash
qm set 9000 --serial0 socket --vga serial0
```

## Step 11: Enable QEMU guest agent

```bash
qm set 9000 --agent enabled=1
```

## Step 12: Convert the VM into a template

```bash
qm template 9000
```

## Step 13: Confirm in Proxmox UI

In Proxmox, you should now see a template named:

```text
ubuntu-2404-cloudinit-template
```

This template can now be cloned by Terraform.

## Step 14: Run Terraform from your Mac

From your Terraform project folder:

```bash
terraform fmt
terraform init
terraform validate
terraform plan
```

If the plan looks correct:

```bash
terraform apply
```

Terraform should create your Kubernetes VMs and generate the Kubespray inventory file.

## Quick mental model

```text
Ubuntu ISO
  = manual installer

Ubuntu cloud image
  = pre-installed Ubuntu disk image

Proxmox cloud-init template
  = reusable VM template Terraform can clone

Terraform
  = creates VMs from the template

Kubespray
  = SSHs into those VMs and installs Kubernetes
```

## Troubleshooting

### Terraform cannot find the template

Make sure the template name in Proxmox exactly matches:

```text
ubuntu-2404-cloudinit-template
```

or update your Terraform variable:

```hcl
template_name = "your-actual-template-name"
```

### VMs are created but SSH does not work

Check that Terraform injected your public key:

```hcl
ssh_pubkey = "ssh-rsa AAAA..."
```

Also check the cloud-init user:

```hcl
ssh_user = "ubuntu"
```

Then try:

```bash
ssh ubuntu@10.0.0.101
```

### VMs do not get the correct IP

Check the Terraform `ipconfig0` value:

```hcl
ipconfig0 = "ip=${each.value.ip}/24,gw=${var.gateway}"
```

Also confirm your gateway is correct, for example:

```hcl
gateway = "10.0.0.1"
```

### Template uses the wrong storage

This guide assumes VM disks go to:

```text
local-lvm
```

If your Proxmox storage has a different name, update the commands and Terraform variable accordingly.