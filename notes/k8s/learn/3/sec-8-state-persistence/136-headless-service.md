# Headless Services
- headless-service.yml
```yml
apiVersion: v1
kind: Service
metadata:
    name: mysql-h
spec:
    ports:
    - port: 3306
    selector:
      app: mysql
    clusterIP: None
```

- deployment-definition.yml
```yml
apiVersion: apps/v1
kind: StatefulSet
metadata:
    name: mysql-deployment
    labels:
        app: mysql
spec:
    serviceName: mysql-h
    replicas: 3
    matchLabels:
        app: mysql
    template:
        metadata:
            name: myapp-pod
            labels:
                app: mysql
        spec:
            containers:
            - name: mysql
              image: mysql
```