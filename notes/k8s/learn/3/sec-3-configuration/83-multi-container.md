# Multi Container Design Patterns
## Init
```yml
apiVersion: v1
kind: Pod
metadata:
    name: simple-webapp
    labels:
        name: simple-webapp
spec:
    containers:
    - name: web-app
      image: web-app
      ports:
        - containerPort: 8080
    initContainers:
    - name: db-checker
      image: busybox
      command: 'wait-for-db-to-start.sh'
    - name: api-checker
      image: busybox
      command: 'wait-for-another-api.sh'
```

## Sidecar
```yml
apiVersion: v1
kind: Pod
metadata:
    name: simple-webapp
    labels:
        name: simple-webapp
spec:
    containers:
    - name: web-app
      image: web-app
      ports:
        - containerPort: 8080
    initContainers:
    - name: db-checker
      image: busybox
      command: 'wait-for-db-to-start.sh'
      restartPolicy: Always
```