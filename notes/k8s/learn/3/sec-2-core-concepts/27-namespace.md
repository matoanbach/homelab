# Namespace
```
mysql.connect("db-service")
mysql.connect("db-service.dev.svc.cluster.local")
```

- Switch namespace: 
```sh
kubectl config set-context $(kubectl config current-context) --namespace=dev
```