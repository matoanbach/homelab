# Replica Controller
- rc-definition.yml
```yml
apiVersion: v1
kind: ReplicationController
metadata:
    name: myapp-rc
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
            - name: nginx-controller
              image: nginx

    replicas: 3
```

# RelicaSet
- rs-definition.yml
```yml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
    name: myapp-replicaset
    labels:
        app: myapp
        type: front-end
spec:
    template:
        metedata:
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
- scale replicas
    1. kubectl scale --replicas=6 -f replicaset-definition.yml
    2. kubectl scale --replicas=6 replicaset myapp-replicaset
    3. kubectl apply -f ...