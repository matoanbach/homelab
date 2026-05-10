# Relicas Set
- It's a configuration telling us how many pods we want for an app and it makes sure the desired number of pods are running

## Example
```yml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
    name: myapp-relicaset
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
    replicas: 6
    selector:
        matchLabels:
            type: front-end
```