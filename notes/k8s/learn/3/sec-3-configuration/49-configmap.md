# ConfigMap
```yml
apiVersion: v1
kind: ConfigMap
metadata:
    name: app-config
data:
    APP_COLOR: blue
    APP_MODE: prod
```

- pod.yml
```yml
apiVersion: v1
kind: Pod
metadata:
    name: simple-webapp-color
spec:
    containers:
    - name: simple-webapp-color
      image: simple-webapp-color
      ports:
         - containerPort: 8080
      envFrom:
         - configMapRef:
                name: app-config
```