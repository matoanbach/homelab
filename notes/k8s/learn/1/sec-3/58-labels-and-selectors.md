## Selectors
```yaml
apiVersion: v1
kind: Pod
metadata:
    name: simple-webapp
    labels:
        app: App1
        Function: Front-end
spec:
    containers:
    - name: simple-webapp
      image: simple-webapp
      ports:
        - containerPort: 8080
```

### Select
```bash
kubectl get pods --selector app=App1
```

### ReplicaSet and Annotations
```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
    name: simple-webapp
    labels:
        app: App1
        function: Front-end
    annotations:
        buildVersion: 1.34
spec:
    replicas: 3
    selector:
        matchLabels:
            app: App1
        template:
            metadata:
                labels:
                    app: App1
                    function: Front-end
            spec:
                containers:
                - name: simple-webapp
                  image: simple-webapp
```