# Argo CD

## Purpose

Argo CD is the GitOps controller for this platform. It watches a Git repository and applies the desired Kubernetes state to the cluster.

## Why It Is Needed

- Keeps cluster state in Git
- Removes manual `kubectl apply` as the normal deployment path
- Becomes the base for later components and app delivery

## Prerequisites

- Working `kubectl` access to the cluster
- A Git repository that will hold manifests or Helm charts
- CoreDNS working in the cluster

## Install Method

Argo CD is the bootstrap exception to the Helm-first rule.

- Install Argo CD itself once with the official manifest
- After that, let Argo CD manage Helm charts and plain YAML from Git

This keeps the first install simple and avoids needing Argo CD to install itself before it exists.

## Installation

The official Argo CD getting-started guide installs into the `argocd` namespace:

```bash
kubectl create namespace argocd
kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

For the first login, port-forward the API server:

```bash
kubectl -n argocd port-forward svc/argocd-server 8080:443
```

Get the initial admin password:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
```

Optional local CLI on macOS:

```bash
brew install argocd
```

## Configuration

Once Argo CD is running, use it to manage both:

- Helm charts for third-party components
- plain YAML for cluster-specific resources

For this project, most later platform components should be represented as Argo CD `Application` resources that point at Helm charts and values stored in Git.

## First Application

Create a namespace for the first managed app:

```bash
kubectl create namespace apps
```

Then register an application that points to the repo path you want Argo CD to manage.

Example manifest:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: platform-root
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/your-user/your-repo.git
    targetRevision: main
    path: apps
  destination:
    server: https://kubernetes.default.svc
    namespace: apps
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

Apply it:

```bash
kubectl apply -f app.yaml
```

## Verification

```bash
kubectl get pods -n argocd
kubectl get applications -n argocd
argocd app list
```

Expected result:

- Argo CD pods are `Running`
- The application appears in the UI and syncs successfully

## Troubleshooting

- If the UI is unreachable, confirm the port-forward is still running.
- If apps stay `OutOfSync`, check the repo path and branch.
- If sync fails on CRDs, install operators before resources that depend on them.

## Notes For This Cluster

- Start with manual installation, then move Argo CD to self-manage later.
- Pin versions instead of relying on the floating `stable` branch once the platform settles.
- Keep Argo CD external access simple at first: port-forward now, ingress later.

## Reference

- https://argo-cd.readthedocs.io/en/stable/getting_started/
