## Node Affinity
```yaml
apiVersion: v1
kind: Pod
metadata:
    name: myapp-pod
spec:
    containers:
    - name: data-processor
      image: data-processor
    nodeSelector:
       size: Large
```

## Node Affinity
```yaml
apiVersion: v1
kind: Pod
metadata:
    name: myapp-pod
spec:
    containers:
    - name: data-processor
      image: data-processor
    affinity:
      nodeAffinity:
        requiredDuringSechudelingIgnoredDuringExecution:
            nodeSelectorTerm:
            - matchExpressions:
              - key: size
                operator: In | NotIn | Exists
                values:
                - Large
                - Medium
```

## Node Affinity Types
- Available
    - `requiredDuringSchedulingIngoredDuringExecution`
    - `preferredDuringSchedulingIgnoredDuringExecution`
    - `requiredDuringSchedulingRequiredExecution`