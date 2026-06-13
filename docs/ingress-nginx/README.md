# NGINX Ingress Controller

## Purpose

NGINX Ingress Controller gives the cluster a standard HTTP and HTTPS entry point for applications.

## Why It Is Needed

- Routes hostnames and paths to services
- Gives apps a normal Kubernetes ingress layer
- Lets Cloudflare Tunnel point at one ingress entry instead of many app services

## Prerequisites

- Working cluster networking
- A decision on exposure strategy for bare metal

## Recommended Pattern For This Project

Because this cluster is self-hosted and `cloudflared` runs on a separate VM, the target flow for this project is:

```text
Cloudflare Tunnel VM -> MetalLB IP on ingress-nginx -> app services
```

That means `ingress-nginx` should be exposed as a `LoadBalancer` service after MetalLB is installed.

## Install Method

This component should be installed with Helm.

- Helm manages the controller `Deployment`, `Service`, RBAC, and ingress class resources.
- We still write our own `Ingress` objects for applications.

## Installation

Install with Helm:

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.ingressClassResource.name=nginx \
  --set controller.ingressClass=nginx \
  --set controller.service.type=LoadBalancer
```

If `ingress-nginx` already exists as a `ClusterIP` service, switch it with `helm upgrade` using the same values and `controller.service.type=LoadBalancer`.

## Configuration

For this cluster:

- install MetalLB first
- keep `controller.service.type=LoadBalancer`
- route Cloudflare Tunnel to the `EXTERNAL-IP` assigned to the ingress controller service
- add `Ingress` resources per app as needed

## Example Ingress

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: sample-app
  namespace: apps
spec:
  ingressClassName: nginx
  rules:
    - host: app.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: sample-app
                port:
                  number: 80
```

## Verification

```bash
kubectl get pods -n ingress-nginx
kubectl get svc -n ingress-nginx
kubectl get ingressclass
```

Expected result:

- controller pods are `Running`
- `nginx` ingress class exists
- `ingress-nginx-controller` has an `EXTERNAL-IP` after MetalLB is installed
- ingress resources with `ingressClassName: nginx` are picked up by the controller

## Troubleshooting

- If no ingress class appears, check the controller chart values.
- If requests return 404, verify the hostname and service name match the ingress rule.
- If no `EXTERNAL-IP` appears, confirm MetalLB is installed and the service type is `LoadBalancer`.

## Notes For This Cluster

- The official ingress-nginx bare-metal docs describe `MetalLB`, `NodePort`, and `hostNetwork` options.
- For this project, MetalLB-backed `LoadBalancer` service is the cleanest fit for the separate `cloudflared` VM.
- Keep Cloudflare hostname routing at the tunnel layer, and keep per-app routing inside Kubernetes `Ingress` resources.

## Reference

- https://kubernetes.github.io/ingress-nginx/deploy/baremetal/
