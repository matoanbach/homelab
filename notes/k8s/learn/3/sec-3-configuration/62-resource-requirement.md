# Resource Request
```yml
apiVersion: v1
kind: Pod
metadata:
    name: simple-webapp-color
    labels:
        name: simple-webapp-color
spec:
    containers:
        - name: simple-webapp-color
          image: simple-webapp-color
          ports:
            - containerPort: 8080
          resources:
            requests:
                memory: "4Gi"
                cpu: 2
            limits:
                memory: "2Gi"
                cpu: 2
```

# LimitRange
```yml
apiVersion: 1
kind: LimitRange
metadata:
    name: cpu-resource-contraint
spec:
    limits:
        - default:
            cpu: 500m
          defaultRequest:
            cpu: 500m
          max:
            cpu: "1"
          min:
            cpu: 100m
          type: Container
```

# Resource Quotas
```yml
apiVersion: v1
kind: ResourceQuota
metadata:
    name: my-resource-quota
spec:
    hard:
        requests.cpu: 4
        requests.memory: 4Gi
        limits.cpu: 10
        limits.memory: 10Gi
```