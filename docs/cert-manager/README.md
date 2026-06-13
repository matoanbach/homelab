# cert-manager

## Purpose

cert-manager automates certificate issuance and renewal inside Kubernetes.

## Why It Is Needed

- Provides TLS for public app hostnames
- Removes manual certificate handling
- Fits well with Cloudflare DNS and GitOps workflows

## Recommended Challenge Type

Use Cloudflare `DNS-01`.

Why:

- this cluster does not rely on inbound port 80
- Cloudflare Tunnel is already part of the design
- DNS-based validation works cleanly for self-hosted environments

## Prerequisites

- A domain in Cloudflare
- A Cloudflare API token with:
  - `Zone - DNS - Edit`
  - `Zone - Zone - Read`

## Install Method

This component should be installed with Helm.

- Helm manages the cert-manager controllers and CRDs.
- We still write our own `ClusterIssuer`, `Certificate`, and ingress annotations.

## Installation

Install cert-manager with Helm:

```bash
helm repo add jetstack https://charts.jetstack.io --force-update
helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.20.2 \
  --set crds.enabled=true
```

## Configuration

## Cloudflare Secret

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: cloudflare-api-token-secret
  namespace: cert-manager
type: Opaque
stringData:
  api-token: <CLOUDFLARE_API_TOKEN>
```

## ClusterIssuer Example

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-cloudflare
spec:
  acme:
    email: you@example.com
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-cloudflare
    solvers:
      - dns01:
          cloudflare:
            apiTokenSecretRef:
              name: cloudflare-api-token-secret
              key: api-token
```

## Ingress Example

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: sample-app
  namespace: apps
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-cloudflare
spec:
  ingressClassName: nginx
  tls:
    - hosts:
        - app.example.com
      secretName: sample-app-tls
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
kubectl get pods -n cert-manager
kubectl get clusterissuer
kubectl get certificaterequests -A
kubectl get certificates -A
```

Expected result:

- cert-manager pods are `Running`
- the `ClusterIssuer` is `Ready`
- the TLS secret is created in the app namespace

## Troubleshooting

- If the issuer is not ready, verify the Cloudflare token permissions.
- If DNS challenges fail, check the zone name and token scope.
- If an ingress never receives a cert, confirm the host matches the Cloudflare zone you control.

## Notes For This Cluster

- DNS-01 is the right default here.
- Do not depend on HTTP-01 while the platform is tunnel-first.
- Pin the chart version and revisit it during cluster upgrades.

## Reference

- https://cert-manager.io/docs/installation/helm/
- https://cert-manager.io/docs/configuration/acme/dns01/cloudflare/
