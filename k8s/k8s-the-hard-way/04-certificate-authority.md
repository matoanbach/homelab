# Provisioning a CA and Generating TLS Certificates (Manual Commands)

This lab provisions a **PKI (Public Key Infrastructure)** using **OpenSSL** to bootstrap a **Certificate Authority (CA)** and generate TLS certificates for Kubernetes components.

All commands below are intended to be run from the **jumpbox** (Ubuntu 24.04 VM).

![K8s diagram](https://github.com/matoanbach/homelab/blob/main/k8s/assets/k8s-the-hard-way/ca-cert.svg)

> **Note:** I run **all commands manually** (no `for` loops). The original tutorial uses loops; this README keeps everything explicit.

---

## Cluster Context

Proxmox + Ubuntu VM layout (example):

- `jumpbox` → `10.0.0.22`
- `server` → `10.0.0.23`
- `node-0` → `10.0.0.24`
- `node-1` → `10.0.0.25`

---

## 1) Review the OpenSSL Config

The `ca.conf` file defines certificate “profiles” (CN, Organization, SANs, key usage) for each component.

```bash
cd /root/kubernetes-the-hard-way
cat ca.conf
```

---

## 2) Create the Certificate Authority (CA)

Generate the CA private key and self-signed root certificate:

```bash
openssl genrsa -out ca.key 4096

openssl req -x509 -new -sha512 -noenc   -key ca.key -days 3653   -config ca.conf   -out ca.crt
```

**Outputs:**

- `ca.key` — CA **private** key (keep on jumpbox)
- `ca.crt` — CA **public** certificate (copy to every machine)

---

## 3) Generate Component Certificates (Manual)

For each component, run:

1. generate private key (`.key`)
2. generate CSR (`.csr`)
3. sign CSR with CA to produce certificate (`.crt`)

### 3.1 admin

```bash
openssl genrsa -out admin.key 4096

openssl req -new -key admin.key -sha256   -config ca.conf -section admin   -out admin.csr

openssl x509 -req -days 3653 -in admin.csr   -copy_extensions copyall   -sha256 -CA ca.crt   -CAkey ca.key   -CAcreateserial   -out admin.crt
```

### 3.2 node-0 (kubelet identity)

```bash
openssl genrsa -out node-0.key 4096

openssl req -new -key node-0.key -sha256   -config ca.conf -section node-0   -out node-0.csr

openssl x509 -req -days 3653 -in node-0.csr   -copy_extensions copyall   -sha256 -CA ca.crt   -CAkey ca.key   -CAcreateserial   -out node-0.crt
```

### 3.3 node-1 (kubelet identity)

```bash
openssl genrsa -out node-1.key 4096

openssl req -new -key node-1.key -sha256   -config ca.conf -section node-1   -out node-1.csr

openssl x509 -req -days 3653 -in node-1.csr   -copy_extensions copyall   -sha256 -CA ca.crt   -CAkey ca.key   -CAcreateserial   -out node-1.crt
```

### 3.4 kube-proxy

```bash
openssl genrsa -out kube-proxy.key 4096

openssl req -new -key kube-proxy.key -sha256   -config ca.conf -section kube-proxy   -out kube-proxy.csr

openssl x509 -req -days 3653 -in kube-proxy.csr   -copy_extensions copyall   -sha256 -CA ca.crt   -CAkey ca.key   -CAcreateserial   -out kube-proxy.crt
```

### 3.5 kube-scheduler

```bash
openssl genrsa -out kube-scheduler.key 4096

openssl req -new -key kube-scheduler.key -sha256   -config ca.conf -section kube-scheduler   -out kube-scheduler.csr

openssl x509 -req -days 3653 -in kube-scheduler.csr   -copy_extensions copyall   -sha256 -CA ca.crt   -CAkey ca.key   -CAcreateserial   -out kube-scheduler.crt
```

### 3.6 kube-controller-manager

```bash
openssl genrsa -out kube-controller-manager.key 4096

openssl req -new -key kube-controller-manager.key -sha256   -config ca.conf -section kube-controller-manager   -out kube-controller-manager.csr

openssl x509 -req -days 3653 -in kube-controller-manager.csr   -copy_extensions copyall   -sha256 -CA ca.crt   -CAkey ca.key   -CAcreateserial   -out kube-controller-manager.crt
```

### 3.7 kube-api-server

```bash
openssl genrsa -out kube-api-server.key 4096

openssl req -new -key kube-api-server.key -sha256   -config ca.conf -section kube-api-server   -out kube-api-server.csr

openssl x509 -req -days 3653 -in kube-api-server.csr   -copy_extensions copyall   -sha256 -CA ca.crt   -CAkey ca.key   -CAcreateserial   -out kube-api-server.crt
```

### 3.8 service-accounts

```bash
openssl genrsa -out service-accounts.key 4096

openssl req -new -key service-accounts.key -sha256   -config ca.conf -section service-accounts   -out service-accounts.csr

openssl x509 -req -days 3653 -in service-accounts.csr   -copy_extensions copyall   -sha256 -CA ca.crt   -CAkey ca.key   -CAcreateserial   -out service-accounts.crt
```

### 3.9 Verify outputs

```bash
ls -1 *.crt *.key *.csr
```

---

## 4) Distribute Certificates (Manual)

### 4.1 Worker nodes (node-0 and node-1)

On each worker, certificates go under:

- `/var/lib/kubelet/ca.crt`
- `/var/lib/kubelet/kubelet.crt`
- `/var/lib/kubelet/kubelet.key`

#### node-0

```bash
ssh root@node-0 "mkdir -p /var/lib/kubelet/"

scp ca.crt root@node-0:/var/lib/kubelet/

scp node-0.crt root@node-0:/var/lib/kubelet/kubelet.crt
scp node-0.key root@node-0:/var/lib/kubelet/kubelet.key
```

#### node-1

```bash
ssh root@node-1 "mkdir -p /var/lib/kubelet/"

scp ca.crt root@node-1:/var/lib/kubelet/

scp node-1.crt root@node-1:/var/lib/kubelet/kubelet.crt
scp node-1.key root@node-1:/var/lib/kubelet/kubelet.key
```

### 4.2 Control plane server

Per the upstream README, copy these to the server home directory:

```bash
scp   ca.key ca.crt   kube-api-server.key kube-api-server.crt   service-accounts.key service-accounts.crt   root@server:~/
```

> Security note: in a stricter setup you would keep `ca.key` only on the jumpbox. This lab copies it to `server` to match the upstream instructions.

---

## 5) What’s next?

The following client certificates will be used in the next lab to generate kubeconfig files:

- `kube-proxy.crt/.key`
- `kube-controller-manager.crt/.key`
- `kube-scheduler.crt/.key`
- `admin.crt/.key`
- (kubelet client creds as part of node config)

Next: **05-kubernetes-configuration-files.md**

## Commands Cheat Sheet

| **Task**                               | **Command**                                                                                                                                       |
| -------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Generate CA Private Key**            | `openssl genrsa -out ca.key 4096`                                                                                                                 |
| **Generate CA Certificate**            | `openssl req -x509 -new -sha512 -noenc -key ca.key -days 3653 -config ca.conf -out ca.crt`                                                        |
| **Generate Private Key for Component** | `openssl genrsa -out <component>.key 4096`                                                                                                        |
| **Generate CSR for Component**         | `openssl req -new -key <component>.key -sha256 -config ca.conf -section <component> -out <component>.csr`                                         |
| **Sign Certificate with CA**           | `openssl x509 -req -days 3653 -in <component>.csr -copy_extensions copyall -sha256 -CA ca.crt -CAkey ca.key -CAcreateserial -out <component>.crt` |
