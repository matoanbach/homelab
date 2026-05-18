# Liveness Probe
```yml
apiVersion: v1
kind: Pod
metadata:
    name: simple-webapp
    labels:
        name: simple-webapp
spec:
    containers:
    - name: simple-webapp
      image: simple-webapp
      ports:
        - containerPort: 8080
      livenessProbe:
        httpGet:
            path: /api/healthy
            port: 8080
```

```yml
livenessProbe:
    httpGet:
        path: /api/healthy
        port: 8080
    initialDelaySeconds: 10
    periodSeconds: 5
    failureThreshold: 8
```
```yml
livenessProbe:
    tcpSocket:
        port: 3306
```
```yml
livenesProbe:
    exec:
        command:
            - cat
            - /app/is_healthy
```