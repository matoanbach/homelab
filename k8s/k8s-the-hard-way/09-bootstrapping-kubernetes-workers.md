# Bootstrapping the Kubernetes Worker Nodes

In this lab you will bootstrap two Kubernetes worker nodes. The following components will be installed: [runc](https://github.com/opencontainers/runc), [container networking plugins](https://github.com/containernetworking/cni), [containerd](https://github.com/containerd/containerd), [kubelet](https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet), and [kube-proxy](https://kubernetes.io/docs/concepts/cluster-administration/proxies).

## Prerequisites

The commands in this section must be run from the `jumpbox`.

Copy the Kubernetes binaries and systemd unit files to each worker instance:

```bash
for HOST in node-0 node-1; do
  SUBNET=$(grep ${HOST} machines.txt | cut -d " " -f 4)
  sed "s|SUBNET|$SUBNET|g" \
    configs/10-bridge.conf > 10-bridge.conf

  sed "s|SUBNET|$SUBNET|g" \
    configs/kubelet-config.yaml > kubelet-config.yaml

  scp 10-bridge.conf kubelet-config.yaml \
  root@${HOST}:~/
done
```

```bash
for HOST in node-0 node-1; do
  scp \
    downloads/worker/* \
    downloads/client/kubectl \
    configs/99-loopback.conf \
    configs/containerd-config.toml \
    configs/kube-proxy-config.yaml \
    units/containerd.service \
    units/kubelet.service \
    units/kube-proxy.service \
    root@${HOST}:~/
done
```

```bash
for HOST in node-0 node-1; do
  scp \
    downloads/cni-plugins/* \
    root@${HOST}:~/cni-plugins/
done
```

The commands in the next section must be run on each worker instance: `node-0`, `node-1`. Login to the worker instance using the `ssh` command. Example:

```bash
ssh root@node-0
```

## Provisioning a Kubernetes Worker Node

Install the OS dependencies:

```bash
{
  apt-get update
  apt-get -y install socat conntrack ipset kmod
}
```

> The socat binary enables support for the `kubectl port-forward` command.

Disable Swap

Kubernetes has limited support for the use of swap memory, as it is difficult to provide guarantees and account for pod memory utilization when swap is involved.

Verify if swap is disabled:

```bash
swapon --show
```

If output is empty then swap is disabled. If swap is enabled run the following command to disable swap immediately:

```bash
swapoff -a
```

> To ensure swap remains off after reboot consult your Linux distro documentation.

Create the installation directories:

```bash
mkdir -p \
  /etc/cni/net.d \
  /opt/cni/bin \
  /var/lib/kubelet \
  /var/lib/kube-proxy \
  /var/lib/kubernetes \
  /var/run/kubernetes
```

Install the worker binaries:

```bash
{
  mv crictl kube-proxy kubelet runc \
    /usr/local/bin/
  mv containerd containerd-shim-runc-v2 containerd-stress /bin/
  mv cni-plugins/* /opt/cni/bin/
}
```

### Configure CNI Networking

Create the `bridge` network configuration file:

```bash
mv 10-bridge.conf 99-loopback.conf /etc/cni/net.d/
```

To ensure network traffic crossing the CNI `bridge` network is processed by `iptables`, load and configure the `br-netfilter` kernel module:

```bash
{
  modprobe br-netfilter
  echo "br-netfilter" >> /etc/modules-load.d/modules.conf
}
```

```bash
{
  echo "net.bridge.bridge-nf-call-iptables = 1" \
    >> /etc/sysctl.d/kubernetes.conf
  echo "net.bridge.bridge-nf-call-ip6tables = 1" \
    >> /etc/sysctl.d/kubernetes.conf
  sysctl -p /etc/sysctl.d/kubernetes.conf
}
```

### Configure containerd

Install the `containerd` configuration files:

```bash
{
  mkdir -p /etc/containerd/
  mv containerd-config.toml /etc/containerd/config.toml
  mv containerd.service /etc/systemd/system/
}
```

### Configure the Kubelet

Create the `kubelet-config.yaml` configuration file:

```bash
{
  mv kubelet-config.yaml /var/lib/kubelet/
  mv kubelet.service /etc/systemd/system/
}
```

### Configure the Kubernetes Proxy

```bash
{
  mv kube-proxy-config.yaml /var/lib/kube-proxy/
  mv kube-proxy.service /etc/systemd/system/
}
```

### Start the Worker Services

```bash
{
  systemctl daemon-reload
  systemctl enable containerd kubelet kube-proxy
  systemctl start containerd kubelet kube-proxy
}
```

Check if the kubelet service is running:

```bash
systemctl is-active kubelet
```

```text
active
```

Be sure to complete the steps in this section on each worker node, `node-0` and `node-1`, before moving on to the next section.

## Verification

Run the following commands from the `jumpbox` machine.

List the registered Kubernetes nodes:

```bash
ssh root@server \
  "kubectl get nodes \
  --kubeconfig admin.kubeconfig"
```

```
NAME     STATUS   ROLES    AGE    VERSION
node-0   Ready    <none>   1m     v1.32.3
node-1   Ready    <none>   10s    v1.32.3
```

## Summary of What Broke

### Symptoms (kubelet logs)
On the worker node, `kubelet` started but failed to register with the API server, repeatedly showing errors like:

- `Unable to register node with API server ... forbidden`
- `node "<something>" cannot read "<something else>", only its own Node object`
- failures accessing:
  - `nodes`
  - `leases.coordination.k8s.io`
  - `csinodes.storage.k8s.io`

Example pattern:
- kubelet tries to register `node-0.kubernetes.local`
- API sees kubelet authenticated as `system:node:node-0`
- authorization fails because the names don’t match

---

## What I Did Wrong

### 1) Node name mismatch (FQDN vs short name)
My worker node hostname was:

- `hostname` / `hostname -f` → `node-0.kubernetes.local`

But my kubelet **client identity** was built around the short name:

- kubelet authenticates as → `system:node:node-0`

Because Node Authorization expects the kubelet’s identity (`system:node:<nodeName>`) to match the Node object name kubelet uses, kubelet could not read or create the Node object it was trying to register.

✅ **In short:**  
I generated kubelet credentials for `node-0`, but kubelet tried to register as `node-0.kubernetes.local`.

---

### 2) (Later) I repeated the mistake on node-1 by copying the wrong override
While switching to `node-1`, I accidentally left this in the systemd drop-in:

```ini
Environment="KUBELET_EXTRA_ARGS=--hostname-override=node-0"
```

That meant node-1’s kubelet would try to register as `node-0` (wrong), which can cause collisions or confusing behavior.

✅ **Correct should be:**
- node-0 → `--hostname-override=node-0`
- node-1 → `--hostname-override=node-1`

---

## Why This Happens (Root Cause)

Kubelet registers a Node object using a **node name** derived from hostname/FQDN unless overridden.

Kubelet authenticates to the API server using a client certificate whose Subject CN is usually:

- `system:node:<nodeName>`

With Node Authorization, the kubelet is only allowed to access resources that match its own node name, such as:

- `Node/<nodeName>`
- `Lease/<nodeName>` in `kube-node-lease`
- `CSINode/<nodeName>`

So if kubelet tries to act as `node-0.kubernetes.local` but is authenticated as `system:node:node-0`, authorization fails.

---

## The Solution I Used (Fastest Fix)

### Fix: Force kubelet’s node name to match its client identity
I fixed the mismatch by overriding kubelet’s node name to the short name used in the certificate.

#### On **node-0**
Create systemd drop-in config:

```bash
sudo mkdir -p /etc/systemd/system/kubelet.service.d
cat <<'EOF' | sudo tee /etc/systemd/system/kubelet.service.d/10-hostname-override.conf
[Service]
Environment="KUBELET_EXTRA_ARGS=--hostname-override=node-0"
EOF
```

Ensure kubelet unit includes `$KUBELET_EXTRA_ARGS`:

```bash
cat <<'EOF' | sudo tee /etc/systemd/system/kubelet.service.d/20-execstart.conf
[Service]
ExecStart=
ExecStart=/usr/local/bin/kubelet \
  --config=/var/lib/kubelet/kubelet-config.yaml \
  --kubeconfig=/var/lib/kubelet/kubeconfig \
  --v=2 \
  $KUBELET_EXTRA_ARGS
EOF
```

Reload + restart:

```bash
sudo systemctl daemon-reload
sudo systemctl restart kubelet
```

---

## How I Verified It Worked

### On the worker node
1) Confirm kubelet is running with the override:

```bash
ps aux | grep '[k]ubelet'
```

Expected to include:

```text
--hostname-override=node-0
```

2) Confirm kubelet registered successfully:

```bash
sudo journalctl -u kubelet -n 100 --no-pager
```

Expected messages like:

- `Successfully registered node`
- `NodeReady`

---

### From the jumpbox / control plane
Confirm nodes show up and are Ready:

```bash
ssh root@server \
  "kubectl get nodes --kubeconfig admin.kubeconfig"
```

Expected:

```text
NAME     STATUS   ROLES    AGE    VERSION
node-0   Ready    <none>   ...    ...
node-1   Ready    <none>   ...    ...
```

---

## Prevention / Best Practice (What I’ll Do Next Time)

Pick **one node naming scheme** and keep it consistent across:

- worker hostnames
- kubelet client cert CN (`system:node:<name>`)
- kubelet kubeconfig identity
- node registration name

Two safe options:

### Option A (recommended for KTHW labs)
Use short names everywhere:
- `node-0`, `node-1`
- set `--hostname-override=node-0` / `node-1`

### Option B
Use FQDN everywhere:
- `node-0.kubernetes.local`, `node-1.kubernetes.local`
- generate kubelet certs and kubeconfigs using the FQDN as the node name

---

## Appendix: Fixing the node-1 copy mistake

If node-1 accidentally had:

```text
--hostname-override=node-0
```

Update it to:

```ini
Environment="KUBELET_EXTRA_ARGS=--hostname-override=node-1"
```

Then:

```bash
sudo systemctl daemon-reload
sudo systemctl restart kubelet
ps aux | grep '[k]ubelet'
```

---

Next: [Configuring kubectl for Remote Access](10-configuring-kubectl.md)