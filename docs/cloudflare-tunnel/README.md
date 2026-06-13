# Cloudflare Tunnel

## Purpose

Cloudflare Tunnel exposes selected services from the cluster without opening inbound ports on the home router.

## Why It Is Needed

- Safely publishes applications to the internet
- Keeps the public edge outside the cluster
- Works well with a private self-hosted cluster on a home LAN

## Prerequisites

- A domain managed in Cloudflare
- Access to Cloudflare Zero Trust
- A running `cloudflared` VM on the same LAN as the cluster
- `ingress-nginx` exposed through MetalLB with a reachable `EXTERNAL-IP`

## Install Method

This component is outside the cluster in this project.

- Install and manage `cloudflared` on the separate VM
- Keep the tunnel route configuration in Cloudflare
- Do not try to model the public hostname mapping as a Helm chart first

## Tunnel Strategy

Use one tunnel on the separate VM and route public hostnames to the MetalLB-backed ingress controller service.

Recommended target pattern:

```text
http://<ingress-metallb-ip>
```

## Installation

Install `cloudflared` on the VM and authenticate it with your Cloudflare tunnel.

The VM should be able to reach the MetalLB IP assigned to `ingress-nginx-controller` over the LAN.

## Configuration

1. In the Cloudflare dashboard, create a tunnel and copy the tunnel token.
2. Install or configure `cloudflared` on the separate VM.
3. Add a public hostname route that points to the MetalLB IP of `ingress-nginx`.

Example route target:

```text
http://10.0.0.240
```

4. Keep application-specific hostname and path routing inside Kubernetes `Ingress` resources.

For example:

- `argocd.example.com` -> `http://10.0.0.240`
- `app.example.com` -> `http://10.0.0.240`

Ingress then decides which backend service gets each hostname.

Start with HTTP from the tunnel VM to the ingress LAN IP. Revisit HTTPS to the origin later after cert-manager and origin certificate behavior are settled.

## Verification

```bash
kubectl get svc -n ingress-nginx ingress-nginx-controller
```

Expected result:

- `ingress-nginx-controller` has a MetalLB `EXTERNAL-IP`
- the `cloudflared` VM can reach that IP on the LAN
- the public hostname reaches the ingress controller and then the app

## Troubleshooting

- If the app is unreachable, verify the Cloudflare route target matches the MetalLB IP.
- If the tunnel connects but traffic fails, test the ingress IP from the `cloudflared` VM first.
- If the tunnel route works but the app still fails, inspect the Kubernetes `Ingress` resource and backend `Service`.

## Notes For This Cluster

- Start by exposing `ingress-nginx`, not every service individually.
- This component lets the platform avoid opening router ports.
- In this project, MetalLB and `ingress-nginx` provide the stable LAN origin, and Cloudflare Tunnel publishes it.

## Reference

- https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/deployment-guides/kubernetes/
