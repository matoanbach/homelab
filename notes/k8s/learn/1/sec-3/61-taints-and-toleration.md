## Taints - Node
```bash
kubectl taint nodes node-name key=value:taint-effect [NoSchedule | PreferNoSchedule | NoExecute]
kubectl taint nodes node1 app=myapp:NoSchedule
```

## Tolerations - Pods
```bash
kubectl taint nodes node1 app=blue:NoSchedule
```
- pod-definitions.yaml:
```yaml
apiVersion: v1
kind: Pod
metadata:
    name: myapp-pod
spec:
    containers:
    - name: nginx-container
        image: nginx
    tolerations:
    - key: app
        operator: "Equal"
        value: blue
        effect: NoSchedule
```