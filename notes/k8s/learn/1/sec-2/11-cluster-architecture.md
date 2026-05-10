# Cluster Architecture
<img src="https://github.com/matoanbach/homelab/blob/main/pics/2.11.1.png"/>
- The digram represents an reference example architecture for a kuberbernetes cluster. The actual distribution of components can vary based on cluster setup and requirements.

- In the digram, each node runs the `kube-proxy` component. You need a network proxy component on each node to ensure that the Service API and associated behaviors on your cluster network. However, some network plugins provide their own, third party implementation of proxying. When you use that kind of network plugin, the node does not need to run `kube-proxy`.

## Control Plane Components
- The control plane's components make global decisions about the cluster (for example, scheduling), as well as detecting and responding to cluster events (for example, starting up a new pod when a Deployment's `replica` field is unsatisfied).

- Control plane components can be run on any machine in the cluster. However, for simplicity, setup scripts typically start all control plane components on the same machine, and do not run user containers on this machine.

### kube-apiserver
- The API server is a component of the Kubernetes control plane that exposes the Kubernetes API. The API server is the front end for the Kubernetes control plane.

- The main implementation of a Kubernetes API server is `kube-apiserver`. It is designed to scale horizontally - that is, it scales by deploying more instances. You can run serveral instances of kube-apiserver and balance traffic between those instances.

### etcd
- Consistant and highly-available key value store used as Kubernetes' backing store for all cluster data.
- If your kubernetes cluster uses etcd as its backing store, make sure you have a back up plan for the data.
- You can find in-depth information about etcd in the official documentation.

### kube-scheduler
- It watches for newly created Pods with no assigned node, and selects a node for them to run on.

- Factors taken into accounts for scheduling decision include: individual and collective resource requirements, hardware/software/policy constraints, affinity and anti-affinity specfications, data locality, inter-workdload interference, and deadlines.

### kube-control-manager
- it runs controller processes.
- Logically, each controller is a separate process, but to reduce complexity, they are compiled into a single binary and run in a single process.

- There are many different types of controllers. Some of them are:
    - Node controller: Responsible for noticing and respoding when nodes go down.
    - Job controller: Watches for Job objects that represent one-off tasks, then creates Pods to run those tasks to completion.
    - EndpointSlice controller: Populates EndpointSlice objects (to provide a link between Services and Pods).
    - ServiceAccount controller: Create default ServiceAccounts for new namespaces.

### cloud-controller-manager
- A Kubernetes control plane components that embeds cloud-specific control logic. The cloud controller manager lets you think your cluster into your cloud provider's API, and seperates out the components that only interact with your cluster.

- The cloud-controller-manager only runs controllers that are specific to your cloud provider. If you are running Kubernetes on your own premises, or in a learning environment inside your own PC, the cluster does not have a cloud controller manager.

- As with the `kube-controller-manager`, the cloud-controller-manager combines serveral logically independent control loops into a single binaray that you run as a single process. You can scale horizontally (run more than one copy) to improve performance or to help tolerate failures.

- The following controllers can have cloud provider dependencies:
    - Node controller: For checking the cloud provider to determine if a node has been deleted in the cloud after it stops responding
    - Route controller: For setting up routes in the underlying cloud infrastructure
    - Serviec controller: For creating, updating and deleting cloud provider load balancers.