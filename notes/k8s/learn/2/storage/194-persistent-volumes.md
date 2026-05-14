# Persistent Volume
## What is it?
- A persistent volume, or PV, is a kubernetes object that represents a piece of storage available in the cluster.
- It is usually created by a cluster adminstrator.

## Why do we use it?
- Without PV, storage is often configured directly inside each Pod YAML file.
- That becomes hard to manage when you have many pods and many users
- PersistentVolumes solve this by making storage more centralized.
- Instead of each user configuring storage manually, an admin can create a pool of storage, and applications can request pieces of it later using `PersistentVolumeClaims`.