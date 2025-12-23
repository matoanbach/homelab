# Generating Kubernetes Configuration Files for Authentication (No Loops)

In this lab you will generate [Kubernetes client configuration files](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/), typically called **kubeconfigs**, which configure Kubernetes clients to connect and authenticate to Kubernetes API Servers.

> **Note**
> - Run these commands in the same directory where you generated the TLS certificates in the **Generating TLS Certificates** lab.
> - Be careful with typos: the command is `kubectl config set-cluster` (not `set-cluser`), and `admin.kubeconfig` (not `admin..kubeconfig`).

## Client Authentication Configs

In this section you will generate kubeconfig files for:
- the **kubelet** (one kubeconfig per node),
- **kube-proxy**,
- **kube-controller-manager**,
- **kube-scheduler**,
- and the **admin** user.

---

## The kubelet Kubernetes Configuration Files

When generating kubeconfig files for kubelets, the client certificate matching the kubelet's node name must be used. This ensures kubelets are properly authorized by the Kubernetes [Node Authorizer](https://kubernetes.io/docs/reference/access-authn-authz/node/).

### node-0.kubeconfig

```bash
kubectl config set-cluster kubernetes-the-hard-way   --certificate-authority=ca.crt   --embed-certs=true   --server=https://server.kubernetes.local:6443   --kubeconfig=node-0.kubeconfig

kubectl config set-credentials system:node:node-0   --client-certificate=node-0.crt   --client-key=node-0.key   --embed-certs=true   --kubeconfig=node-0.kubeconfig

kubectl config set-context default   --cluster=kubernetes-the-hard-way   --user=system:node:node-0   --kubeconfig=node-0.kubeconfig

kubectl config use-context default   --kubeconfig=node-0.kubeconfig
```

### node-1.kubeconfig

```bash
kubectl config set-cluster kubernetes-the-hard-way   --certificate-authority=ca.crt   --embed-certs=true   --server=https://server.kubernetes.local:6443   --kubeconfig=node-1.kubeconfig

kubectl config set-credentials system:node:node-1   --client-certificate=node-1.crt   --client-key=node-1.key   --embed-certs=true   --kubeconfig=node-1.kubeconfig

kubectl config set-context default   --cluster=kubernetes-the-hard-way   --user=system:node:node-1   --kubeconfig=node-1.kubeconfig

kubectl config use-context default   --kubeconfig=node-1.kubeconfig
```

Results:

```text
node-0.kubeconfig
node-1.kubeconfig
```

---

## The kube-proxy Kubernetes Configuration File

Generate a kubeconfig file for the `kube-proxy` service:

```bash
kubectl config set-cluster kubernetes-the-hard-way   --certificate-authority=ca.crt   --embed-certs=true   --server=https://server.kubernetes.local:6443   --kubeconfig=kube-proxy.kubeconfig

kubectl config set-credentials system:kube-proxy   --client-certificate=kube-proxy.crt   --client-key=kube-proxy.key   --embed-certs=true   --kubeconfig=kube-proxy.kubeconfig

kubectl config set-context default   --cluster=kubernetes-the-hard-way   --user=system:kube-proxy   --kubeconfig=kube-proxy.kubeconfig

kubectl config use-context default   --kubeconfig=kube-proxy.kubeconfig
```

Results:

```text
kube-proxy.kubeconfig
```

---

## The kube-controller-manager Kubernetes Configuration File

Generate a kubeconfig file for the `kube-controller-manager` service:

```bash
kubectl config set-cluster kubernetes-the-hard-way   --certificate-authority=ca.crt   --embed-certs=true   --server=https://server.kubernetes.local:6443   --kubeconfig=kube-controller-manager.kubeconfig

kubectl config set-credentials system:kube-controller-manager   --client-certificate=kube-controller-manager.crt   --client-key=kube-controller-manager.key   --embed-certs=true   --kubeconfig=kube-controller-manager.kubeconfig

kubectl config set-context default   --cluster=kubernetes-the-hard-way   --user=system:kube-controller-manager   --kubeconfig=kube-controller-manager.kubeconfig

kubectl config use-context default   --kubeconfig=kube-controller-manager.kubeconfig
```

Results:

```text
kube-controller-manager.kubeconfig
```

---

## The kube-scheduler Kubernetes Configuration File

Generate a kubeconfig file for the `kube-scheduler` service:

```bash
kubectl config set-cluster kubernetes-the-hard-way   --certificate-authority=ca.crt   --embed-certs=true   --server=https://server.kubernetes.local:6443   --kubeconfig=kube-scheduler.kubeconfig

kubectl config set-credentials system:kube-scheduler   --client-certificate=kube-scheduler.crt   --client-key=kube-scheduler.key   --embed-certs=true   --kubeconfig=kube-scheduler.kubeconfig

kubectl config set-context default   --cluster=kubernetes-the-hard-way   --user=system:kube-scheduler   --kubeconfig=kube-scheduler.kubeconfig

kubectl config use-context default   --kubeconfig=kube-scheduler.kubeconfig
```

Results:

```text
kube-scheduler.kubeconfig
```

---

## The admin Kubernetes Configuration File

Generate a kubeconfig file for the `admin` user:

```bash
kubectl config set-cluster kubernetes-the-hard-way   --certificate-authority=ca.crt   --embed-certs=true   --server=https://127.0.0.1:6443   --kubeconfig=admin.kubeconfig

kubectl config set-credentials admin   --client-certificate=admin.crt   --client-key=admin.key   --embed-certs=true   --kubeconfig=admin.kubeconfig

kubectl config set-context default   --cluster=kubernetes-the-hard-way   --user=admin   --kubeconfig=admin.kubeconfig

kubectl config use-context default   --kubeconfig=admin.kubeconfig
```

Results:

```text
admin.kubeconfig
```

---

## Distribute the Kubernetes Configuration Files

### Copy kubelet + kube-proxy kubeconfigs to node-0

```bash
ssh root@node-0 "mkdir -p /var/lib/{kube-proxy,kubelet}"

scp kube-proxy.kubeconfig root@node-0:/var/lib/kube-proxy/kubeconfig
scp node-0.kubeconfig root@node-0:/var/lib/kubelet/kubeconfig
```

### Copy kubelet + kube-proxy kubeconfigs to node-1

```bash
ssh root@node-1 "mkdir -p /var/lib/{kube-proxy,kubelet}"

scp kube-proxy.kubeconfig root@node-1:/var/lib/kube-proxy/kubeconfig
scp node-1.kubeconfig root@node-1:/var/lib/kubelet/kubeconfig
```

### Copy controller kubeconfigs to the server node

```bash
scp admin.kubeconfig   kube-controller-manager.kubeconfig   kube-scheduler.kubeconfig   root@server:~/
```

Next: [Generating the Data Encryption Config and Key](06-data-encryption-keys.md)
