# Self-Hosted Kubernetes Platform on Proxmox

This project turns a self-hosted Kubernetes cluster on Proxmox into a small production-style platform for deploying and operating applications.

The top-level README stays intentionally short. Each platform component will have its own dedicated README with step-by-step setup instructions.

## Current Foundation

Already completed:

- Proxmox server
- Terraform VM provisioning
- Ubuntu cloud-init template
- Kubespray Kubernetes cluster
- `kubectl` access from Mac

## Platform Components

These are the components we want to add, in priority order:

1. Argo CD
2. NGINX Ingress Controller
3. MetalLB
4. Cloudflare Tunnel
5. cert-manager
6. Storage
7. One real app
8. Jenkins
9. Secrets management
10. Monitoring
11. Logging
12. Security hardening

## Why This Order

- Argo CD establishes GitOps first.
- Ingress defines app routing.
- MetalLB gives bare-metal services a reachable LAN IP.
- Cloudflare Tunnel publishes that ingress entry to the internet.
- cert-manager adds TLS automation.
- Storage unlocks stateful workloads.
- One real app proves the platform works end to end.
- Jenkins completes the CI side of the workflow.
- Secrets, monitoring, logging, and security hardening come after the base platform is working.

## Documentation

Each component has its own setup guide:

- [Argo CD](docs/argocd/README.md)
- [NGINX Ingress Controller](docs/ingress-nginx/README.md)
- [MetalLB](docs/metallb/README.md)
- [Cloudflare Tunnel](docs/cloudflare-tunnel/README.md)
- [cert-manager](docs/cert-manager/README.md)
- [Storage](docs/storage/README.md)
- [One real app](docs/app/README.md)
- [Jenkins](docs/jenkins/README.md)
- [Secrets management](docs/secrets/README.md)
- [Monitoring](docs/monitoring/README.md)
- [Logging](docs/logging/README.md)
- [Security hardening](docs/security/README.md)

## Install Convention

Use this repo with one default rule:

- install third-party platform components with Helm
- keep Helm configuration in `values.yaml` files committed to Git
- write plain YAML only for cluster-specific glue resources such as `Ingress`, `ClusterIssuer`, `SealedSecret`, `NetworkPolicy`, and Argo CD `Application` objects
- treat Argo CD bootstrap and Cloudflare Tunnel as the main exceptions, because Argo CD starts from an official manifest and Cloudflare Tunnel is configured outside the cluster

Each component README should cover:

- Purpose
- Why it is needed in this project
- Prerequisites
- Installation
- Configuration
- Verification
- Troubleshooting
- Notes specific to this cluster

## Target Delivery Flow

```text
Code push
-> Jenkins
-> GHCR image push
-> Git manifest or Helm update
-> Argo CD sync
-> Kubernetes deployment
```

## Project Goal

The final result should demonstrate:

- Self-hosted Kubernetes on Proxmox
- GitOps with Argo CD
- Application delivery through Jenkins and GHCR
- External access through Cloudflare Tunnel
- TLS with cert-manager
- Persistent storage for stateful workloads
- Monitoring and logging for operations
- Basic Kubernetes security practices
