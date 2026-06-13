# Storage

## Purpose

Storage gives stateful workloads persistent volumes instead of relying on ephemeral node disks.

## Recommended First Choice

Use Longhorn.

## Why It Is Needed

- PostgreSQL, Redis, Grafana, and other stateful apps need PVCs
- The current cluster has no `StorageClass`
- A platform without storage will block at the first real stateful workload

## Prerequisites

- Enough free disk on each node
- Longhorn node prerequisites installed on the VMs
- Helm available on the admin machine

Before installing, verify the cluster is ready for Longhorn's prerequisites, especially iSCSI support on every node.

## Install Method

This component should be installed with Helm.

- Helm manages the Longhorn control plane, CSI components, UI, and `StorageClass` resources.
- We still write our own PVCs and storage settings for applications.

## Installation

```bash
helm repo add longhorn https://charts.longhorn.io
helm repo update
helm install longhorn longhorn/longhorn --namespace longhorn-system --create-namespace --version 1.12.0
```

## Configuration

After installation, decide:

- whether Longhorn should be the default `StorageClass`
- whether replica count should be reduced for this small lab cluster
- whether backups should be configured now or later

## Verification

```bash
kubectl -n longhorn-system get pods
kubectl get storageclass
```

Expected result:

- Longhorn pods are `Running`
- a Longhorn `StorageClass` appears

## Example PVC Test

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: smoke-test-pvc
  namespace: default
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
```

Apply it and confirm the claim binds.

## Troubleshooting

- If pods stay pending, check Longhorn node prerequisites and disk availability.
- If PVCs do not bind, confirm the `StorageClass` exists and the provisioner is healthy.
- If storage usage grows too fast, reduce replica count and keep test volumes small.

## Notes For This Cluster

- This cluster currently has about 40 GiB ephemeral storage per node, so capacity is limited.
- Start conservatively.
- Do not move databases onto Longhorn until you confirm the storage layer is healthy under failure and restart scenarios.

## Reference

- https://longhorn.io/docs/latest/deploy/install/install-with-helm/
