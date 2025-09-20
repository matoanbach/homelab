# homelab — Networking • Linux • Kubernetes

Learning-in-public repo for my homelab. I’m practicing the core skills that power reliable systems:

- **Linux administration**: users/groups, storage (LVM), SELinux, systemd, logs, firewall, containers.
- **Networking**: IPv4/IPv6, subnets & routing, VLANs, DHCP/DNS basics, packet tools (`ip`, `ss`, `tcpdump`).
- **Kubernetes**: pods/deployments, services, scheduling (taints/tolerations/affinity), resources & probes, troubleshooting.
- **Automation & CI**: Ansible for repeatable setups; scripts for containerized test runs.
## Hardware
- HP z840 with Dual E5-2660, 10 core 2.60Ghz, 64G RAM, and 500G Storage
<img src="https://github.com/matoanbach/homelab/blob/main/images/hardware.png"/>

## Repo layout
```
ansible/                  # setup automation
k8s/learn/                # k8s manifests & notes
networking/               # labs and diagrams
red-hat-enterprise-linux/ # linux admin tasks & checklists
README.md
```
