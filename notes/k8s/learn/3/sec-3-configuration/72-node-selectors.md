# Node Selectors
```yml
apiVersion: v1
kind: Pod
metedata:
    name: myapp-pod
spec:
    containers:
        - name: data-processor
          image: data-processor
    nodeSelector:
        size: Large
```