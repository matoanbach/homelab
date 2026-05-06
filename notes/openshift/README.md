# Run OpenShift on Proxmox with Terraform

## Architecture Overview
- 3 master nodes - compacted and run control plan (etcd, API server, controllers) and application workloads

## Cluster Specification

| Item | Value |
|---|---|
| Platform | OpenShift on Proxmox |
| Install method | Agent-based installer |
| Cluster type | 3-node compact cluster |
| Cluster name | `ocp` |
| Base domain | `internal.example.com` |
| Full cluster domain | `ocp.internal.example.com` |
| Control-plane replicas | `3` |
| Worker replicas | `0` |
| Workload scheduling | Workloads run on control-plane nodes |
| Proxmox host | `10.0.0.19` |
| Proxmox node name | `turtle` |
| Proxmox bridge | `vmbr0` |
| ISO storage | `local` |
| VM disk storage | `local-lvm` |
| Installer files | `install-config.yaml`, `agent-config.yaml` |
| Generated ISO | `agent.x86_64.iso` |

The Agent-based installer generates a bootable ISO containing the information required to deploy the cluster. The install flow uses `install-config.yaml` and `agent-config.yaml` as input files.

### Node Layout

| Node | Role | vCPU | RAM | Disk | MAC Address |
|---|---|---:|---:|---:|---|
| `ocp-master-1` | Control plane + workload | 6 | 20 GB | 70 GB | `BC:24:11:44:22:32` |
| `ocp-master-2` | Control plane + workload | 6 | 20 GB | 70 GB | `BC:24:11:44:22:35` |
| `ocp-master-3` | Control plane + workload | 6 | 20 GB | 70 GB | `BC:24:11:44:22:36` |

### Total VM Resources

| Resource | Total |
|---|---:|
| vCPU | 18 |
| RAM | 60 GB |
| VM disk | 210 GB |

### Notes

This is a compact OpenShift cluster. There are no dedicated worker nodes. Application workloads such as Harbor and Jenkins can run on the control-plane nodes, but resource limits should be used carefully because control-plane services and workloads share the same nodes.

---

## Network Layout

| Purpose | Hostname / DNS Record | IP |
|---|---|---:|
| Proxmox host | `turtle` | `10.0.0.19` |
| Bastion / DNS server | `ocp-bastion` | `10.0.0.20` |
| OpenShift API VIP | `api.ocp.internal.example.com` | `10.0.0.21` |
| OpenShift internal API VIP | `api-int.ocp.internal.example.com` | `10.0.0.21` |
| OpenShift apps wildcard | `*.apps.ocp.internal.example.com` | `10.0.0.22` |
| Master 1 | `ocp-master-1.ocp.internal.example.com` | `10.0.0.23` |
| Master 2 | `ocp-master-2.ocp.internal.example.com` | `10.0.0.24` |
| Master 3 | `ocp-master-3.ocp.internal.example.com` | `10.0.0.25` |
| Default gateway | Router / LAN gateway | `10.0.0.1` |
| Machine network | Node network | `10.0.0.0/24` |
| Cluster network | Pod network | `10.128.0.0/14` |
| Service network | Kubernetes service network | `172.30.0.0/16` |

### DNS Records

Example `dnsmasq` records:

```conf
address=/api.ocp.internal.example.com/10.0.0.21
address=/api-int.ocp.internal.example.com/10.0.0.21
address=/.apps.ocp.internal.example.com/10.0.0.22

address=/ocp-master-1.ocp.internal.example.com/10.0.0.23
address=/ocp-master-2.ocp.internal.example.com/10.0.0.24
address=/ocp-master-3.ocp.internal.example.com/10.0.0.25
```

## Set up a workstation
- We need a dedicated VM to run all the commands
- Required tools:
1. Terraform (>= 1.0.0)
2. openshift-install
3. oc
4. nmstatectl
5. dnsmasq

### Use dnf (gotta use RHEL for this)
```
subscription-manager register

```

### Terraform:
```
yum install -y yum-utils
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
yum -y install terraform
```

### Openshift-install & openshift cli
```
mkdir -p ~/ocp-tools
cd ~/ocp-tools

curl -LO https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable/openshift-install-linux.tar.gz
curl -LO https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable/openshift-client-linux.tar.gz

tar -xzf openshift-install-linux.tar.gz
tar -xzf openshift-client-linux.tar.gz

sudo mv openshift-install oc kubectl /usr/local/bin/

openshift-install version
oc version --client
kubectl version --client
```

### nmstatectl
```
dnf install nmstate cargo -y
curl https://sh.rustup.rs -sSf | sh
cargo install nmstatectl
```

### dnsmasq
```
dnf install -y dnsmasq bind-utils
nmcli con add con-name lab-net type ethernet ifname ens18 ipv4.method manual ipv4.address 10.0.0.20/24 ipv4.gateway 10.0.0.1 ipv4.dns 10.0.0.20,1.1.1.1
nmcli con up lab-net
systemctl restart NetworkManager
```
#### dnsmasq conf
```
vim /etc/dnsmasq.d/ocp.conf
```
- Paste this in:
```
listen-address=127.0.0.1,10.0.0.20
bind-interfaces

server=1.1.1.1
server=8.8.8.8

address=/api.ocp.internal.example.com/10.0.0.21
address=/api-int.ocp.internal.example.com/10.0.0.21
address=/.apps.ocp.internal.example.com/10.0.0.22

address=/ocp-master-1.ocp.internal.example.com/10.0.0.23
address=/ocp-master-2.ocp.internal.example.com/10.0.0.24
address=/ocp-master-3.ocp.internal.example.com/10.0.0.25
```
- Start it:
```
sudo firewall-cmd --add-service=dns --permanent
sudo firewall-cmd --reload
sudo systemctl enable --now dnsmasq
sudo systemctl restart dnsmasq
```
- Try it:
```
dig @10.0.0.20 api.ocp.internal.example.com
dig @10.0.0.20 api-int.ocp.internal.example.com
dig @10.0.0.20 console-openshift-console.apps.ocp.internal.example.com
dig @10.0.0.20 ocp-master-1.ocp.internal.example.com
```


## Create API Users for Terraform
- Workstation will install things from the proxmox server so that workstation vm needs a user and role
```
# Create user only if it does not exist
pveum user add terraform@pve

# Create or update Terraform role
pveum role modify terraform-role -privs "Datastore.Allocate Datastore.AllocateSpace Datastore.AllocateTemplate Datastore.Audit Pool.Allocate Pool.Audit SDN.Audit SDN.Use Sys.Audit Sys.Console Sys.Modify VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.CPU VM.Config.Cloudinit VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.PowerMgmt VM.GuestAgent.Audit VM.GuestAgent.Unrestricted"

# Assign role broadly for this homelab
pveum aclmod / -user terraform@pve -role terraform-role

# Create token only if you do not already have one
pveum user token add terraform@pve terraform-token --privsep=0

# output:
┌──────────────┬──────────────────────────────────────┐
│ key          │ value                                │
╞══════════════╪══════════════════════════════════════╡
│ full-tokenid │ terraform@pve!terraform-token        │
├──────────────┼──────────────────────────────────────┤
│ value        │ xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx │
└──────────────┴──────────────────────────────────────┘
```

> Save the value for later use

## Configuration file
