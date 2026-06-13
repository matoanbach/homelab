# One Real App

## Purpose

This guide turns the platform from a collection of components into a working end-to-end deployment.

## Goal

Deploy one real application that proves:

- Argo CD syncs from Git
- ingress routes traffic correctly
- Cloudflare Tunnel exposes the app
- cert-manager issues TLS
- GHCR stores the image

## Why It Is Needed

- Proves the platform works end to end
- Gives Argo CD, ingress, TLS, and CI a real target
- Turns the project from infrastructure-only into an actual delivery workflow

## Prerequisites

- Argo CD installed and able to sync from Git
- ingress-nginx running
- Cloudflare Tunnel routing traffic into the cluster
- cert-manager ready for the public hostname
- an application image available in `ghcr.io`

## Install Method

This component is ours, so it does not have to start with Helm.

- For the first pass, raw YAML is fine and easier to understand.
- Later, move the app into a Helm chart if it grows or needs environment-specific values.

The main rule is different from third-party components:

- platform software is usually installed with Helm
- the first app can stay plain YAML until there is a reason to chart it

## Installation

For the first pass:

- create the namespace
- apply the `Deployment`, `Service`, and `Ingress`
- let Argo CD own those manifests from Git

## Recommended First Pass

Start with a simple stateless app before adding a database.

Suggested shape:

- one namespace
- one `Deployment`
- one `Service`
- one `Ingress`
- one image hosted in `ghcr.io`

## Configuration

Store the app manifests or Helm chart in the repo path that Argo CD watches.

## Example Namespace

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: apps
```

## Example Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample-app
  namespace: apps
spec:
  replicas: 2
  selector:
    matchLabels:
      app: sample-app
  template:
    metadata:
      labels:
        app: sample-app
    spec:
      containers:
        - name: app
          image: ghcr.io/your-user/your-app:latest
          ports:
            - containerPort: 3000
          resources:
            requests:
              cpu: 100m
              memory: 128Mi
            limits:
              cpu: 500m
              memory: 256Mi
          readinessProbe:
            httpGet:
              path: /
              port: 3000
```

## Example Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: sample-app
  namespace: apps
spec:
  selector:
    app: sample-app
  ports:
    - port: 80
      targetPort: 3000
```

## Example Ingress

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

## GitOps Placement

Example layout:

```text
apps/
  sample-app/
    deployment.yaml
    service.yaml
    ingress.yaml
```

## Verification

```bash
kubectl get pods -n apps
kubectl get svc -n apps
kubectl get ingress -n apps
kubectl describe certificate -n apps
```

Expected result:

- pods are `Running`
- service endpoints exist
- ingress resolves through Cloudflare Tunnel
- TLS secret exists

## Troubleshooting

- If the app is unreachable, test the service before the ingress.
- If TLS is missing, inspect the cert-manager challenge resources.
- If Argo CD shows sync errors, confirm the repo path and namespace.

## Notes For This Cluster

- Keep the first app small.
- Add PVCs only after storage is fully working.
- Add a database in a later pass, not in the first smoke test.

## Reference

- ../argocd/README.md
- ../ingress-nginx/README.md
- ../cloudflare-tunnel/README.md
- ../cert-manager/README.md
- ../jenkins/README.md
