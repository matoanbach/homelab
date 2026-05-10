# Cluster Architecture
## 1. Control Plan components
1. kube-apiserver
- It's the main entry point for kubectl, controllers, scheduler, and nodes all communicate throught it.

2. etcd
- Key-value database that stores the cluster state

3. kube-scheduler
- Chooses which node a new pod should run on.

4. kube-controller-manager
- it's there to keep checking if our cluster has the right state.

## 2. Node components
1. kubelet
- It's responsible for creating a new pod based on a set of specs, healing a pod if it's down, making sure the pod keep running and have the right state.

2. kube-proxy
- it's to handler Service networking and forwards traffic to the right pods.

3. container runtime (containerd, CRI-O, etc.)
- it's to pull images and runs containers, usually containerd or CRI-O