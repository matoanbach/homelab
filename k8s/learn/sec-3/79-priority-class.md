## Priority Class
```yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
    name: high-priority
value: 1000000000
description: "Priority class for mission critical pods"
preemptionPolicy: PreemptLowerPriority | never
```

```yaml
apiVersion: v1
kind: Pod
metadata:
    name: nginx
    labels:
        name: nginx
spec:
    containers:
    - name: nginx
      image: nginx
      ports:
        - containerPort: 8080
    priorityClassName: high-priority
```