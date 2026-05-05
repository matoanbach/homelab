# Proxmox → Kubespray → Kubernetes (1 control plane + 2 workers)

This README takes you from **creating VMs in Proxmox** to a **ready Kubernetes cluster** using **Kubespray** (run from a Docker container so you don’t fight Ansible versions).

---

## Target layout

| Node | Role | IP | Hostname |
|---|---|---:|---|
| cp1 | control-plane + etcd | 10.0.0.23 | cp1 |
| w1 | worker | 10.0.0.24 | w1 |
| w2 | worker | 10.0.0.25 | w2 |

> Replace IPs/usernames to match your lab, but keep node IPs **static** and on the same L2 network/bridge (e.g., `vmbr0`).

---

## 0) Prereqs

- Proxmox host with a bridge like `vmbr0` connected to your LAN
- A Linux machine/VM to act as a **jumpbox/bastion** (where you run Kubespray)
- SSH access to all nodes from the jumpbox
- Internet access from nodes (or you’ll need offline download/proxy setup later)

---

## 1) Create 3 VMs in Proxmox

Create VMs:
- `cp1`
- `w1`
- `w2`

### Recommended VM sizing (lab-friendly)

- **cp1**: 2 vCPU, 4–8 GB RAM, 30–60 GB disk
- **w1/w2**: 2 vCPU, 4 GB RAM, 30–60 GB disk

### Proxmox VM settings

- OS: Ubuntu Server (22.04 or 24.04)
- Network: VirtIO (bridge to `vmbr0`)
- Enable QEMU Guest Agent (optional but helpful)

Install Ubuntu on each VM.

---

## 2) Configure networking + hostnames on each VM

### 2.1 Set hostname

On each node:

```bash
sudo hostnamectl set-hostname cp1   # on cp1
sudo hostnamectl set-hostname w1    # on w1
sudo hostnamectl set-hostname w2    # on w2
```

### 2.2 Set static IP (Ubuntu netplan)

Find your interface name (often something like `enp6s18`):

```bash
ip link
```

Edit netplan (filename varies):

```bash
sudo nano /etc/netplan/00-installer-config.yaml
```

Example (adjust interface + IP + gateway + DNS):

```yaml
network:
  version: 2
  ethernets:
    enp6s18:
      dhcp4: no
      addresses: [10.0.0.23/24]
      routes:
        - to: default
          via: 10.0.0.1
      nameservers:
        addresses: [1.1.1.1, 8.8.8.8]
```

Apply:

```bash
sudo netplan apply
```

Repeat on `w1` and `w2` with their IPs.

### 2.3 (Optional) basic tooling

```bash
sudo apt update
sudo apt -y install curl vim
```

---

## 3) SSH setup (keys + sudo)

Kubespray needs an SSH user that can run `sudo`.

This README uses `ubuntu` as the SSH user. If your nodes use a different username (e.g., `toan`), replace `ubuntu` everywhere.

### 3.1 Generate an SSH key on the jumpbox (if you don’t have one)

```bash
ssh-keygen -t ed25519
```

### 3.2 Copy your SSH key to each node (from jumpbox)

```bash
ssh-copy-id ubuntu@10.0.0.23
ssh-copy-id ubuntu@10.0.0.24
ssh-copy-id ubuntu@10.0.0.25
```

Quick test:

```bash
ssh ubuntu@10.0.0.23 "hostname; hostname -I"
ssh ubuntu@10.0.0.24 "hostname; hostname -I"
ssh ubuntu@10.0.0.25 "hostname; hostname -I"
```

---

## 4) Install Docker on the jumpbox

You’ll run Kubespray from a container.

Check Docker:

```bash
docker --version
```

If needed, install Docker using your distro method (example for Ubuntu):

```bash
sudo apt update
sudo apt -y install docker.io
sudo usermod -aG docker $USER
newgrp docker
docker run hello-world
```

---

## 5) Get Kubespray on the jumpbox

```bash
git clone https://github.com/kubernetes-sigs/kubespray.git
cd kubespray
mkdir -p inventory/proxmox
```

---

## 6) Create an INI inventory

Create `inventory/proxmox/hosts.ini`:

```ini
[all:vars]
ansible_user=ubuntu
ansible_become=true

[all]
cp1 ansible_host=10.0.0.23 ip=10.0.0.23 access_ip=10.0.0.23
w1  ansible_host=10.0.0.24 ip=10.0.0.24 access_ip=10.0.0.24
w2  ansible_host=10.0.0.25 ip=10.0.0.25 access_ip=10.0.0.25

[kube_control_plane]
cp1

[etcd]
cp1

[kube_node]
w1
w2

[k8s_cluster:children]
kube_control_plane
kube_node

[calico_rr]
```

Sanity check:

```bash
ansible-inventory -i inventory/proxmox/hosts.ini --graph
```

---

## 7) Run Kubespray using the official container

From the Kubespray repo root on the jumpbox:

```bash
docker run --rm -it   --mount type=bind,source="$(pwd)",dst=/kubespray   --mount type=bind,source="$HOME/.ssh",dst=/root/.ssh   -w /kubespray   quay.io/kubespray/kubespray:v2.29.0 bash
```

Inside the container, validate connectivity:

```bash
ansible -i inventory/proxmox/hosts.ini all -m ping
ansible -i inventory/proxmox/hosts.ini all -m shell -a "hostname; hostname -I"
```

Deploy the cluster:

```bash
ansible-playbook -i inventory/proxmox/hosts.ini cluster.yml
```

---

## 8) Verify the cluster

On `cp1`:

```bash
kubectl get nodes -o wide
kubectl -n kube-system get pods
```

Expected:
- `cp1`, `w1`, `w2` are `Ready`
- CoreDNS is running
- Calico pods are running

---

## 9) Common issues and quick fixes

### A) SSH auth errors: “Permission denied (publickey,password)”
- Wrong `ansible_user`, or key not copied.

Fix:
- Update `ansible_user=...` in `[all:vars]`
- Re-run `ssh-copy-id user@node`

### B) Inventory IP mismatch: “ip var does not match local ips”
Your `ip=` in inventory must match what the node really has.

Fix:
- On the node: `ip addr`
- Update `ip=` and `access_ip=` accordingly.

### C) Swap failures (`swapoff -a` returning non-zero)
Often harmless if swap is already off, but fix state anyway:

```bash
sudo swapoff -a || true
```

Then rerun the playbook.

### D) Calico FelixConfiguration “default not found”
If the cluster is up (`kubectl get nodes` shows Ready), create it:

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: projectcalico.org/v3
kind: FelixConfiguration
metadata:
  name: default
spec: {}
EOF
```

Then rerun only networking:

```bash
ansible-playbook -i inventory/proxmox/hosts.ini cluster.yml --become --tags network
```

---

## 10) Day-2 additions (optional)

- MetalLB (LoadBalancer on bare metal)
- Ingress controller (NGINX / Traefik)
- Storage (Longhorn / NFS / Ceph)
- Monitoring (Prometheus/Grafana)
