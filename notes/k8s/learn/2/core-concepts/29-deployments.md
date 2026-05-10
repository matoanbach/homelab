# Deployment
- Similar to replica set

## Example
```yml
apiVersion: apps/v1
kind: Deployment
metadata:
    name: myapp-deployment
    labels:
        app: myapp

spec:
    replicas: 3
    strategy:
        type: RollingUpdate
        rollingUpdate:
            maxUnavailable: 1
            maxSurge: 1
        type: Recreate # just another strategy

    selector:
        matchLabels:
            app: myapp
    
    template:
        metadata:
            labels:
                app: myapp
    
    spec:
        containers:
          - name: myapp-container
            image: nginx:1.26
            ports:
                - containerPort: 80

            resources:
                requests:
                    cpu: "100m"
                    memory: "128Mi"
                limits:
                    cpu: "500m"
                    memory: "256Mi"
            
            readinessProbe:
                httpGet:
                    path: /
                    port: 80
                initialDelaySeconds: 5
                periodSeconds: 10
            
            livenessProbe:
                httpGet:
                    path: /
                    port: 80
                initialDelaySeconds: 15
                periodSeconds: 20
```