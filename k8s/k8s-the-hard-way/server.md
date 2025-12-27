# KTHW Server (control plane) — Files-in-Folders Checklist (Sections 01–10)

This README lists **every file KTHW places on the server node** (control plane host), and the **exact folder it must live in**, based on **KTHW sections 01–10**.

Scope includes what KTHW installs/configures on `server` in:
- 03 (hostnames/hosts)
- 04 (cert distribution to server)
- 05 (kubeconfig distribution to server)
- 06 (encryption config distribution to server)
- 07 (etcd bootstrap)
- 08 (control plane bootstrap + RBAC manifest)

No “path variants” are included — only the canonical locations from KTHW 01–10.

---

# 1) Networking / name resolution (KTHW 03)

## `/etc/hosts`
**Purpose:** resolve `server`, `node-0`, `node-1` hostnames without DNS.

**Must contain appended KTHW entries (examples):**
- `IP server.kubernetes.local server`
- `IP node-0.kubernetes.local node-0`
- `IP node-1.kubernetes.local node-1`

**Source:** generated on jumpbox as `hosts`, copied to server, appended into `/etc/hosts`.

**Ownership/perms:** not specified by KTHW.

---

# 2) etcd (KTHW 07)

## `/usr/local/bin/`
**Purpose:** etcd server and client binaries.

**Must contain:**
- `etcd`
- `etcdctl`

**Source:** copied from jumpbox:
- `downloads/controller/etcd`
- `downloads/client/etcdctl`
then moved into `/usr/local/bin/`.

**Ownership/perms:** not specified by KTHW (should be executable).

---

## `/etc/etcd/`
**Purpose:** TLS material used by etcd.

**Must contain:**
- `ca.crt`
- `kube-api-server.crt`
- `kube-api-server.key`

**Source:** generated on jumpbox (Section 04) and copied to server (KTHW copies to `~` then installs into `/etc/etcd/`).

**Ownership/perms:** not specified by KTHW.

---

## `/var/lib/etcd/`
**Purpose:** etcd data directory.

**Must exist:** directory (etcd will populate data files at runtime).

**Source:** created on server.

**Ownership/perms (explicit in KTHW):**
- `chmod 700 /var/lib/etcd`

---

## `/etc/systemd/system/etcd.service`
**Purpose:** systemd unit to run etcd.

**Must contain:**
- `etcd.service`

**Source:** copied from jumpbox `units/etcd.service`, moved into `/etc/systemd/system/`.

**Ownership/perms:** not specified by KTHW.

---

# 3) Kubernetes control plane (KTHW 08)

## `/etc/kubernetes/config/`
**Purpose:** configuration directory for control plane component configs.

**Must contain:**
- `kube-scheduler.yaml`

**Source:** copied from jumpbox `configs/kube-scheduler.yaml`, moved into `/etc/kubernetes/config/`.

**Ownership/perms:** not specified by KTHW.

---

## `/var/lib/kubernetes/`
**Purpose:** central directory for control-plane credentials + configs.

**Must contain (moved into place by KTHW):**
- CA + PKI + secrets:
  - `ca.crt`
  - `ca.key`
  - `kube-api-server.crt`
  - `kube-api-server.key`
  - `service-accounts.crt`
  - `service-accounts.key`
  - `encryption-config.yaml`
- Component kubeconfigs:
  - `kube-controller-manager.kubeconfig`
  - `kube-scheduler.kubeconfig`

**Source:** generated on jumpbox in Sections 04–06, scp’d to server (usually into `~`), then moved into `/var/lib/kubernetes/` during Section 08.

**Ownership/perms:** not specified by KTHW.

---

## `/usr/local/bin/`
**Purpose:** control plane executables.

**Must contain:**
- `kube-apiserver`
- `kube-controller-manager`
- `kube-scheduler`
- `kubectl`

**Source:** copied from jumpbox:
- `downloads/controller/kube-apiserver`
- `downloads/controller/kube-controller-manager`
- `downloads/controller/kube-scheduler`
- `downloads/client/kubectl`
then moved into `/usr/local/bin/`.

**Ownership/perms:** not specified by KTHW (should be executable).

---

## `/etc/systemd/system/`
**Purpose:** systemd unit files for control-plane components.

**Must contain:**
- `kube-apiserver.service`
- `kube-controller-manager.service`
- `kube-scheduler.service`

**Source:** copied from jumpbox `units/*.service`, moved into `/etc/systemd/system/`.

**Ownership/perms:** not specified by KTHW.

---

# 4) RBAC manifest staged on server (KTHW 08)

## `~/kube-apiserver-to-kubelet.yaml`  *(server root home)*
**Purpose:** applied once to grant API server access to Kubelet API on worker nodes.

**Must exist:** the YAML manifest (location can be anywhere; KTHW stages it in `~`).

**Source:** copied from jumpbox `configs/kube-apiserver-to-kubelet.yaml`.

**Ownership/perms:** not specified by KTHW.

---

# 5) Staging files in server home during install (KTHW 04–08)

During KTHW’s scp steps, the following are typically staged in the server’s home directory (`/root`) before being moved to final locations:

- From Section 04:
  - `ca.key`, `ca.crt`
  - `kube-api-server.key`, `kube-api-server.crt`
  - `service-accounts.key`, `service-accounts.crt`
- From Section 05:
  - `kube-controller-manager.kubeconfig`
  - `kube-scheduler.kubeconfig`
  - `admin.kubeconfig` *(used for verification; not moved into `/var/lib/kubernetes/` by KTHW)*
- From Section 06:
  - `encryption-config.yaml`
- From Section 07:
  - `etcd`, `etcdctl`
  - `etcd.service`
- From Section 08:
  - `kube-apiserver`, `kube-controller-manager`, `kube-scheduler`, `kubectl`
  - `kube-apiserver.service`, `kube-controller-manager.service`, `kube-scheduler.service`
  - `kube-scheduler.yaml`
  - `kube-apiserver-to-kubelet.yaml`

After you move files into their final locations, these home-directory copies are not required.

---

# Sanity check commands (minimal)

Run on the **server**:

## A) File existence checks
```bash
# etcd TLS + data dir perms
ls -l /etc/etcd/ca.crt /etc/etcd/kube-api-server.crt /etc/etcd/kube-api-server.key
stat -c "%a %n" /var/lib/etcd

# control plane PKI + encryption config
ls -l /var/lib/kubernetes/ca.crt /var/lib/kubernetes/ca.key
ls -l /var/lib/kubernetes/kube-api-server.crt /var/lib/kubernetes/kube-api-server.key
ls -l /var/lib/kubernetes/service-accounts.crt /var/lib/kubernetes/service-accounts.key
ls -l /var/lib/kubernetes/encryption-config.yaml

# scheduler config
ls -l /etc/kubernetes/config/kube-scheduler.yaml

# kubeconfigs for controller components
ls -l /var/lib/kubernetes/kube-controller-manager.kubeconfig
ls -l /var/lib/kubernetes/kube-scheduler.kubeconfig
```

## B) systemd health
```bash
systemctl daemon-reload
systemctl is-enabled etcd kube-apiserver kube-controller-manager kube-scheduler
systemctl is-active  etcd kube-apiserver kube-controller-manager kube-scheduler
systemctl status     etcd kube-apiserver kube-controller-manager kube-scheduler --no-pager
```

## C) logs (fast triage)
```bash
journalctl -u etcd -n 200 --no-pager
journalctl -u kube-apiserver -n 200 --no-pager
journalctl -u kube-controller-manager -n 200 --no-pager
journalctl -u kube-scheduler -n 200 --no-pager
```

## D) API verification (server-local)
```bash
# admin kubeconfig is staged in ~ per KTHW and used for verification
kubectl cluster-info --kubeconfig admin.kubeconfig
```

---

## Notes on ownership + permissions

- The only explicit permission change in KTHW 01–10 on the server is:
  - `chmod 700 /var/lib/etcd`
- Everything else is implicitly `root:root` because KTHW runs as root.

