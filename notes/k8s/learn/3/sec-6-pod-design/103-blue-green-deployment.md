# Blue green
- Make two deployments: one is green and one is blue
- The blue one is the old deployment, while the green one is the new deployment. In order to reduce the downtime, we have two deployments running, and then switch from the old to the new deployment. If everythin is ok, we can remove the old deployment.
- myapp-green.yml
```yml
apiVersion: apps/v1
kind: Deployment
metadata:
    name: myapp-green
    labels:
        app: myapp
        type: front-end
spec:
    template:
        metadata:
            name: myapp-pod
            labels:
                version: v2
        spec:
            containers:
                - name: app-container
                  image: myapp-image:2.0
    replicas: 5
    selector:
        matchLabels:
            version: v2
```
- myapp-blue.yml
```yml
apiVersion: apps/v1
kind: Deployment
metadata:
    name: myapp-blue
    labels:
        app: myapp
        type: front-end
spec:
    template:
        metadata:
            name: myapp-pod
            labels:
                version: v1
        spec:
            containers:
            - name: app-container
              image: myapp-image:1.0
    replicas: 5
    selector:
        matchLabels:
            version: v1
```
- service-definition.yml
```yml
apiVersion: v1
kind: Service
metadata:
    name: my-service
spec:
    selector:
        version: v1 # v1 -> v2
```