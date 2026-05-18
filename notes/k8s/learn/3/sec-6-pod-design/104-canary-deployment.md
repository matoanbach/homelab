# Canary
- route traffic to both versions
- route a small percentage of traffic to version 2

- myapp-primary.yml
```yml
apiVersion: apps/v1
kind: Deployment
metadata:
    name: myapp-primary
    labels:
        app: myapp
        type: front-end
spec:
    template:
        metadata:
            name: myapp-pod
            labels:
                version: v1
                app: front-end
        spec:
            containers:
            - name: app-container
              image: myapp-image:1.0
    replicas: 5
    selector:
        matchLabels:
            app: front-end
```

- myapp-canary.yml
```yml
apiVersion: apps/v1
kind: Deployment
metadata:
    name: myapp-canary
    labels:
        app: myapp
        type: front-end
spec:
    template:
        metadata:
            name: myapp-pod
            labels:
                version: v2
                app: front-end
        spec:
            containers:
            - name: app-container
              image: myapp-image:2.0
    replicas: 1
    selector:
        matchLabels:
            app: front-end
```