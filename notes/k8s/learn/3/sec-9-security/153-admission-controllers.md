# Admission Controllers
- AlwaysPullImages
- DefaultStorageClass
- EventRateLimit
- NamespaceAutoProvision
- NamespaceAutoProvision
- NamespaceExists
- ...

- Viewing Enabled Admission Controllers
```bash
kube-apiserver -h | grep enable-admissin-plugins
kubectl exec kube-apiserver-controlplane -n kube-system -h | grep enable-admission-plugins
```

```bash
$ ExecStart=/usr/local/bin/kube-apiserver \\
  --advertise-address=${INTERNAL_IP} \\
  --allow-privileged=true \\
  --apiserver-count=3 \\
  --authorization-mode=Node,RBAC \\
  --bind-address=0.0.0.0 \\
  --enable-swagger-ui=true \\
  --etcd-servers=https://127.0.0.1:2379 \\
  --event-ttl=1h \\
  --runtime-config=api/all \\
  --service-cluster-ip-range=10.32.0.0/24 \\
  --service-node-port-range=30000-32767 \\
  --v=2
  --enable-admission-plugins=NodeRestriction,NamespaceAutoProvision
```

```yml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  name: kube-apiserver
  namespace: kube-system
spec:
  containers:
    - command:
        - kube-apiserver
        - --authorization-mode=Node,RBAC
        - --advertise-address=172.17.0.107
        - --allow-privileged=true
        - --enable-bootstrap-token-auth=true
        - --enable-admission-plugins=NodeRestriction,NamespaceAutoProvision
      image: k8s.gcr.io/kube-apiserver-amd64:v1.11.3
      name: kube-apiserver
```