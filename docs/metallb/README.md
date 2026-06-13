# MetalLB

## Purpose

MetalLB gives a bare-metal Kubernetes cluster real `LoadBalancer` services on the local network.

## Why It Is Needed

- Kubernetes on Proxmox does not get cloud load balancers by default
- `ingress-nginx` needs a stable LAN IP that external systems can reach
- the separate `cloudflared` VM needs one simple origin target for app traffic

## Recommended Mode For This Project

Use Layer 2 mode.

- It is the simplest option for a small homelab on one LAN
- it does not require BGP support from the home router
- it fits the current goal of exposing `ingress-nginx`

## Prerequisites

- A working cluster network
- A free IP range on the same LAN as the Kubernetes nodes
- An IP range outside normal DHCP allocation, or DHCP reservations that guarantee no overlap
- Helm available on the admin machine

If kube-proxy is running in IPVS mode, confirm `strictARP` is enabled before troubleshooting MetalLB reachability.

## Install Method

This component should be installed with Helm.

- Helm manages the MetalLB controller, speaker, RBAC, and CRDs
- we still define our own `IPAddressPool` and `L2Advertisement` resources

## Installation

```bash
helm repo add metallb https://metallb.github.io/metallb
helm repo update
helm install metallb metallb/metallb \
  --namespace metallb-system \
  --create-namespace
```

If Pod Security Admission blocks the speaker pods, label the namespace as required by the MetalLB docs.

## Configuration

Pick a small block of unused LAN IPs for `LoadBalancer` services.

Example:

```yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: lan-pool
  namespace: metallb-system
spec:
  addresses:
    - 10.0.0.240-10.0.0.250
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: lan
  namespace: metallb-system
spec:
  ipAddressPools:
    - lan-pool
```

Apply it:

```bash
kubectl apply -f metallb-config.yaml
```

After MetalLB is ready, expose `ingress-nginx` as a `LoadBalancer` service so it receives one of those IPs.

## Verification

```bash
kubectl get pods -n metallb-system
kubectl get ipaddresspools,l2advertisements -n metallb-system
kubectl get svc -n ingress-nginx ingress-nginx-controller
```

Expected result:

- MetalLB controller and speaker pods are `Running`
- the IP pool and `L2Advertisement` exist
- `ingress-nginx-controller` gets an `EXTERNAL-IP` from the configured range

## Troubleshooting

- If no `EXTERNAL-IP` appears, confirm the service type is `LoadBalancer`
- If an IP is assigned but traffic does not arrive, verify the chosen IP range is actually unused on the LAN
- If speaker pods fail admission checks, review namespace security labels
- If reachability is inconsistent, check kube-proxy mode and confirm `strictARP` when using IPVS

## Notes For This Cluster

- Use MetalLB for `ingress-nginx` first, not for many unrelated services
- Keep the IP pool small and intentional
- This gives the separate `cloudflared` VM a stable ingress target on the LAN

## Reference

- https://metallb.io/installation/
- https://metallb.io/configuration/
