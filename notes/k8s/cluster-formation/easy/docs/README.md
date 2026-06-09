# Proxmox + Terraform + Kubespray Setup

This project provisions Kubernetes VMs on Proxmox using Terraform, then uses Kubespray to install Kubernetes.

## Files

```text
kubespray-proxmox/
├── terraform.tf
├── terraform.tfvars
├── inventory.ini.tftpl
├── cloud-init-template.md
└── README.md
```

## Setup Order

```text
1. Check Proxmox storage
2. Create Proxmox API token
3. Create terraform.tfvars
4. Create the Ubuntu cloud-init template
5. Run Terraform
6. Test SSH
7. Run Kubespray
```

## 1. Check Proxmox Storage

On the Proxmox host:

```bash
pvesm status
```

Expected storage usage:

```text
local      → ISO files, cloud images, templates
local-lvm  → VM disks
```

This project uses `local-lvm` for VM disks.

## 2. Create Proxmox API Token

In the Proxmox UI:

```text
Datacenter → Permissions → API Tokens
```

Create a token:

```text
User: terraform@pve
Token ID: terraform-token
Privilege Separation: unchecked
```

Save these values:

```text
Token ID: terraform@pve!terraform-token
Token Secret: shown once by Proxmox
```

If you lose the secret, delete the token and create a new one.

## 3. Get Your SSH Public Key

On your Mac:

```bash
cat ~/.ssh/id_ed25519.pub
```

If it does not exist:

```bash
ssh-keygen -t ed25519 -C "kubespray-proxmox"
cat ~/.ssh/id_ed25519.pub
```

Use your Mac public key, not the Proxmox host key.

## 4. Create `terraform.tfvars`

Create `terraform.tfvars`:

```hcl
proxmox_host = "10.0.0.19"

proxmox_api_token_id = "terraform@pve!terraform-token"

proxmox_api_token_secret = "PASTE_YOUR_TOKEN_SECRET_HERE"

target_node = "turtle"

template_name = "ubuntu-2404-cloudinit-template"

vm_storage = "local-lvm"

bridge = "vmbr0"

gateway = "10.0.0.1"

dns_server = "10.0.0.1"

search_domain = "local"

ssh_user = "ubuntu"

ssh_pubkey = "PASTE_YOUR_MAC_PUBLIC_KEY_HERE"
```

Do not commit `terraform.tfvars` to Git because it contains secrets.

## 5. Create the Cloud-Init Template

Create the Ubuntu cloud-init template before running Terraform.

Follow:

```text
cloud-init-template.md
```

The final Proxmox template should be named:

```text
ubuntu-2404-cloudinit-template
```

Terraform clones this template into:

```text
k8s-cp1 → 10.0.0.101
k8s-w1  → 10.0.0.102
k8s-w2  → 10.0.0.103
```

## 6. Run Terraform

From the project folder:

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

Terraform should create the VMs and generate:

```text
inventory.ini
```

## 7. Verify the VMs

On Proxmox:

```bash
qm config 201
qm config 202
qm config 203
```

Check for:

```text
boot: order=scsi0
serial0: socket
vga: serial0
net0: ...,bridge=vmbr0
ipconfig0: ip=...
```

From your Mac:

```bash
ssh ubuntu@10.0.0.101
ssh ubuntu@10.0.0.102
ssh ubuntu@10.0.0.103
```

If SSH works, the VMs are ready for Kubespray.

## 8. Run Kubespray

Clone Kubespray:

```bash
git clone https://github.com/kubernetes-sigs/kubespray.git
cd kubespray
```

Install dependencies:

```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

Copy the generated inventory:

```bash
mkdir -p inventory/mycluster
cp /path/to/kubespray-proxmox/inventory.ini inventory/mycluster/inventory.ini
```

Run Kubespray:

```bash
ansible-playbook -i inventory/mycluster/inventory.ini \
  --become --become-user=root \
  cluster.yml
```

## Notes

The cloud-init template must exist before Terraform can clone the VMs.

The important Terraform fixes for this setup are:

```text
Use your Mac SSH public key
Use Telmate cloud-init disk block
Add serial0 socket
Use boot order scsi0
```
