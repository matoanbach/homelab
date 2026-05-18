# Secrets
```yml
apiVersion: v1
kind: Secret
metadata:
    name: app-secret
data:
    DB_Host: asjnsdww=
    DB_User: sadooja==
```
- run: `kubectl create -f secret-data.yml`
```bash
echo -n 'mysql' | base64
echo -n 'root' | base64
echo -n 'passwrd' | base64
```

## Secrets in Pods
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
      envFrom:
        - secretRef:
            name: app-secret
```