# Secrets Management

## Purpose

Secrets management prevents committing raw credentials into Git.

## Recommended First Choice

Use Sealed Secrets.

## Why It Is Needed

- GitOps means manifests live in Git
- plain Kubernetes `Secret` objects should not be committed unencrypted
- Sealed Secrets gives a simple first workflow for a self-hosted cluster

## Prerequisites

- `kubectl` access
- `helm` on the admin machine
- `kubeseal` installed locally

Install `kubeseal` on macOS:

```bash
brew install kubeseal
```

## Install Method

This component should be installed with Helm.

- Helm manages the Sealed Secrets controller.
- We still write and commit `SealedSecret` resources in Git.

## Installation

```bash
helm repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets
helm repo update
helm install sealed-secrets sealed-secrets/sealed-secrets --namespace kube-system
```

## Configuration

## Seal A Secret

Create a normal secret manifest without applying it:

```bash
kubectl create secret generic app-secrets \
  --namespace apps \
  --from-literal=DATABASE_URL=postgres://user:pass@db/apps \
  --dry-run=client -o yaml > secret.yaml
```

Seal it for Git:

```bash
kubeseal --format yaml < secret.yaml > sealed-secret.yaml
```

Commit `sealed-secret.yaml`, not `secret.yaml`.

## Example SealedSecret

```yaml
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  name: app-secrets
  namespace: apps
spec:
  encryptedData: {}
  template:
    metadata:
      name: app-secrets
      namespace: apps
```

## Verification

```bash
kubectl get pods -n kube-system | grep sealed
kubectl get sealedsecrets -A
kubectl get secrets -n apps
```

Expected result:

- the controller is running
- applying a `SealedSecret` creates the matching Kubernetes `Secret`

## Troubleshooting

- If `kubeseal` cannot find the controller, specify the controller namespace and name explicitly.
- If decryption fails after reinstalling the controller, confirm the old sealing key still exists.
- Never commit the raw unsealed secret manifest.

## Notes For This Cluster

- This is the simplest first secret workflow for GitOps.
- If secret usage becomes more dynamic later, reevaluate External Secrets or SOPS.

## Reference

- https://github.com/bitnami-labs/sealed-secrets
