# KTHW Worker Nodes (node-0 & node-1) — Files-in-Folders Checklist (Sections 01–10)

This README lists **every file KTHW places on worker nodes** and the **exact folder it must live in**, for **both node-0 and node-1**.

It is derived from KTHW sections:
- 03 (hostnames/hosts)
- 04 (cert distribution to workers)
- 05 (kubeconfig distribution to workers)
- 09 (worker bootstrapping: binaries, configs, systemd, sysctl/modules)
(Sections 01, 02, 06–08, 10 do not add additional worker-node files beyond those.)

---

## Worker-specific variables (what differs between node-0 and node-1)

These files differ per node:

- **Pod subnet** (from `machines.txt`):
  - `10-bridge.conf` (CNI bridge subnet)
  - `kubelet-config.yaml` (node podCIDR/subnet)
- **Node identity credentials**:
  - `/var/lib/kubelet/kubelet.crt`
  - `/var/lib/kubelet/kubelet.key`
  - `/var/lib/kubelet/kubeconfig` (copied from `${HOST}.kubeconfig`)

Everything else is identical.

---

# 1) Networking / name resolution (KTHW 03)

## `/etc/hosts`
**Purpose:** resolve `server`, `node-0`, `node-1` hostnames without DNS.

**Must contain appended KTHW entries (examples):**
- `IP server.kubernetes.local server`
- `IP node-0.kubernetes.local node-0`
- `IP node-1.kubernetes.local node-1`

**Source:** generated on jumpbox as `hosts`, then copied to each worker and appended.

**Ownership/perms:** not specified by KTHW.

---

# 2) CNI (KTHW 09)

## `/opt/cni/bin/`
**Purpose:** CNI plugin binaries.

**Must contain (all files):**
- All binaries copied from jumpbox `downloads/cni-plugins/*` (names depend on the CNI release).

**Source:** downloaded+extracted on jumpbox → copied to worker under `~/cni-plugins/` → moved to `/opt/cni/bin/`.

**Ownership/perms:** not specified by KTHW (should be executable).

---

## `/etc/cni/net.d/`
**Purpose:** CNI network config files used by the bridge + loopback plugins.

**Must contain:**
- `10-bridge.conf`  *(per-node: uses that node’s pod subnet)*
- `99-loopback.conf`

**Source:**
- `10-bridge.conf`: generated on jumpbox from `configs/10-bridge.conf` with `SUBNET` substituted using `machines.txt`.
- `99-loopback.conf`: copied from jumpbox `configs/99-loopback.conf`.
- Both are copied to worker home then moved into `/etc/cni/net.d/`.

**Ownership/perms:** not specified by KTHW.

---

# 3) Kernel module + sysctl wiring for CNI bridge (KTHW 09)

## `/etc/modules-load.d/modules.conf`
**Purpose:** ensure `br-netfilter` loads at boot (so bridged traffic hits iptables).

**Must contain line:**
- `br-netfilter`

**Source:** appended on worker via `echo "br-netfilter" >> /etc/modules-load.d/modules.conf`.

**Ownership/perms:** not specified by KTHW.

---

## `/etc/sysctl.d/kubernetes.conf`
**Purpose:** sysctl settings for bridge → iptables/ip6tables.

**Must contain lines:**
- `net.bridge.bridge-nf-call-iptables = 1`
- `net.bridge.bridge-nf-call-ip6tables = 1`

**Source:** appended on worker via `echo ... >> /etc/sysctl.d/kubernetes.conf`, then applied with:
- `sysctl -p /etc/sysctl.d/kubernetes.conf`

**Ownership/perms:** not specified by KTHW.

---

# 4) containerd (KTHW 09)

## `/etc/containerd/config.toml`
**Purpose:** containerd configuration.

**Must contain:**
- `config.toml`

**Source:** copied from jumpbox `configs/containerd-config.toml` → moved to `/etc/containerd/config.toml`.

**Ownership/perms:** not specified by KTHW.

---

## containerd binaries (installed by KTHW)

### `/bin/`
**Purpose:** container runtime binaries (as installed by the KTHW worker lab).

**Must contain:**
- `containerd`
- `containerd-shim-runc-v2`
- `containerd-stress`

**Source:** downloaded+extracted on jumpbox to `downloads/worker/` → copied to worker home → moved to `/bin/`.

**Ownership/perms:** not specified by KTHW (should be executable).

### IMPORTANT PATH VARIANT (unit-driven)
Some environments use a `containerd.service` that expects containerd under `/usr/local/bin/` or `/usr/bin/`.
**The actual required binary location is whatever path appears in:**
- `ExecStart=` inside `/etc/systemd/system/containerd.service`

If your unit expects a different path, either:
- move the binaries to match the unit, or
- update the unit to match where you installed the binaries.

---

# 5) Worker Kubernetes + runtime binaries (KTHW 09)

## `/usr/local/bin/`
**Purpose:** worker node executables.

**Must contain:**
- `crictl`
- `kubelet`
- `kube-proxy`
- `runc`

**Source:** downloaded+extracted on jumpbox to `downloads/worker/` → copied to worker home → moved to `/usr/local/bin/`.

**Ownership/perms:** not specified by KTHW (should be executable).

> Note: KTHW copies `kubectl` to `~/kubectl` on workers in the scp step, but the worker lab does **not** install it into `/usr/local/bin/`.
> If you want it globally available, you may copy it to `/usr/local/bin/` yourself (optional).

---

# 6) kubelet (KTHW 04, 05, 09)

## `/var/lib/kubelet/`
**Purpose:** kubelet config + kubeconfig + TLS.

**Must contain (KTHW canonical locations):**
- TLS materials (from Section 04):
  - `ca.crt`
  - `kubelet.crt`   *(per-node: copied from `${HOST}.crt`)*
  - `kubelet.key`   *(per-node: copied from `${HOST}.key`)*
- Client auth kubeconfig (from Section 05):
  - `kubeconfig`    *(per-node: copied from `${HOST}.kubeconfig`)*
- Kubelet runtime config (from Section 09):
  - `kubelet-config.yaml` *(per-node subnet substituted on jumpbox)*

**Source:**
- `ca.crt`, `${HOST}.crt`, `${HOST}.key`: generated on jumpbox (openssl CA lab) → copied to this directory and renamed to kubelet.crt/key.
- `${HOST}.kubeconfig`: generated on jumpbox (kubectl config lab) → copied to `/var/lib/kubelet/kubeconfig`.
- `kubelet-config.yaml`: generated on jumpbox from `configs/kubelet-config.yaml` with `SUBNET` substituted → moved here.

**Ownership/perms:** not specified by KTHW.

### IMPORTANT PATH VARIANT: `/var/lib/kubelet/pki/`
Some kubelet units/configs reference certs under:
- `/var/lib/kubelet/pki/ca.crt`
- `/var/lib/kubelet/pki/kubelet.crt`
- `/var/lib/kubelet/pki/kubelet.key`

The KTHW worker + cert labs place these directly under `/var/lib/kubelet/`.
**Only create/use the `pki/` variant if your kubelet unit or kubelet-config.yaml references it.**

How to confirm which layout you are using:
```bash
systemctl cat kubelet | sed -n '/ExecStart/,$p'
grep -nE 'clientCAFile|tlsCertFile|tlsPrivateKeyFile' /var/lib/kubelet/kubelet-config.yaml || true
```

---

# 7) kube-proxy (KTHW 05, 09)

## `/var/lib/kube-proxy/`
**Purpose:** kube-proxy config + kubeconfig.

**Must contain:**
- `kube-proxy-config.yaml`
- `kubeconfig`  ✅ **MUST be a FILE** (not a directory)

**Source:**
- `kube-proxy-config.yaml`: copied from jumpbox `configs/kube-proxy-config.yaml` → moved here.
- `kubeconfig`: generated on jumpbox as `kube-proxy.kubeconfig` → copied to `/var/lib/kube-proxy/kubeconfig`.

**Ownership/perms:** not specified by KTHW.

### CRITICAL WARNING (common failure)
`/var/lib/kube-proxy/kubeconfig` must be a **file**.

Quick check:
```bash
ls -ld /var/lib/kube-proxy/kubeconfig
```

If it is a directory, fix it (on the worker):
```bash
rm -rf /var/lib/kube-proxy/kubeconfig
```

Then re-copy from jumpbox:
```bash
scp kube-proxy.kubeconfig root@node-0:/var/lib/kube-proxy/kubeconfig
# and similarly for node-1
```

---

# 8) systemd units (KTHW 09)

## `/etc/systemd/system/`
**Purpose:** service units to manage the worker components.

**Must contain:**
- `containerd.service`
- `kubelet.service`
- `kube-proxy.service`

**Source:** copied from jumpbox `units/*.service` → moved into place.

**Ownership/perms:** not specified by KTHW.

---

# 9) Directories KTHW creates on workers (KTHW 09)

These directories must exist (KTHW creates them explicitly):
- `/etc/cni/net.d/`
- `/opt/cni/bin/`
- `/var/lib/kubelet/`
- `/var/lib/kube-proxy/`
- `/var/lib/kubernetes/`
- `/var/run/kubernetes/`

KTHW does not require specific files inside:
- `/var/lib/kubernetes/` (worker-side placeholder)
- `/var/run/kubernetes/` (runtime placeholder)

---

# 10) (Optional) Staging files in worker home during install (KTHW 09)

During KTHW’s scp steps, the following are staged in the worker’s home directory before being moved:
- `10-bridge.conf`, `kubelet-config.yaml` (per node)
- `99-loopback.conf`
- `containerd-config.toml`
- `kube-proxy-config.yaml`
- `containerd.service`, `kubelet.service`, `kube-proxy.service`
- worker binaries (crictl/kubelet/kube-proxy/runc/containerd…)
- directory `~/cni-plugins/` containing CNI binaries

After you move them into their final locations, the home directory copies are not required.

---

# Sanity check commands (minimal)

Run on **each worker** (node-0 and node-1):

## A) File-vs-directory checks (most important)
```bash
# kubeconfigs must be FILES
ls -ld /var/lib/kubelet/kubeconfig
ls -ld /var/lib/kube-proxy/kubeconfig
```

## B) CNI present
```bash
ls -l /etc/cni/net.d/10-bridge.conf /etc/cni/net.d/99-loopback.conf
ls -l /opt/cni/bin | head
```

## C) containerd path matches unit
```bash
systemctl cat containerd | sed -n '/ExecStart/,$p'
command -v containerd || true
ls -l /bin/containerd /usr/bin/containerd /usr/local/bin/containerd 2>/dev/null || true
```

## D) kubelet TLS layout matches unit/config
```bash
systemctl cat kubelet | sed -n '/ExecStart/,$p'
grep -nE 'clientCAFile|tlsCertFile|tlsPrivateKeyFile' /var/lib/kubelet/kubelet-config.yaml || true
ls -l /var/lib/kubelet/ca.crt /var/lib/kubelet/kubelet.crt /var/lib/kubelet/kubelet.key 2>/dev/null || true
ls -l /var/lib/kubelet/pki/ca.crt /var/lib/kubelet/pki/kubelet.crt /var/lib/kubelet/pki/kubelet.key 2>/dev/null || true
```

## E) systemd health + logs
```bash
systemctl daemon-reload
systemctl enable containerd kubelet kube-proxy
systemctl is-active containerd kubelet kube-proxy

journalctl -u containerd -n 200 --no-pager
journalctl -u kubelet    -n 200 --no-pager
journalctl -u kube-proxy -n 200 --no-pager
```

## F) Cluster-level verification (from jumpbox or server)
```bash
ssh root@server "kubectl get nodes --kubeconfig admin.kubeconfig -o wide"
```

---

## Notes on ownership + permissions

In the KTHW 01–10 worker steps, **no explicit chmod/chown is required on worker-node files**.
KTHW assumes root execution and relies on normal defaults (files owned by root, binaries executable).

(Contrast: KTHW explicitly sets `chmod 700 /var/lib/etcd` on the server, but that is not a worker step.)
