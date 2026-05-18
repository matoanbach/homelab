# Deployment
- replicaset-definition.yml
```yml
apiVersion: apps/v1
kind: Deployment
metedata:
    name: myapp-deployment
    labels:
        app: myapp
        type: front-end
spec:
    template:
        metadata:
            name: myapp-pod
            labels:
                app: myapp
                type: front-end
        spec:
            containers:
            - name: nginx-container
              image: nginx
    replicas: 3
    selector:
        matchLabels:
            type: front-end
```