## DaemonSet Definition
```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
    name: monitoring-daemon
spec:
    slector:
        matchLabels:
            app: monitoring-agent
    template:
        metadata:
            labels:
                app: monitoring-agent
        spec:
            containers:
            - name: monitoring-agent
              image: monitoring-agent
```

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
    name: monitoring-daemon
spec:
    slector:
        matchLabels:
            app: monitoring-agent
    template:
        metadata:
            labels:
                app: monitoring-agent
        spec:
            containers:
            - name: monitoring-agent
              image: monitoring-agent
```