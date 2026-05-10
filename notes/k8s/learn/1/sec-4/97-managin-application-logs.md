## Logs - Docker
- `docker run -d [pod]`
- `docker logs -f ecf`

## Logs - Kubernetes
- `kubectl create -f event-simulator.yaml`
- `kubectl logs -f event-simulator-pod`

```yaml
apiVersion: v1
kind: Pod
metadata:
    name: event-simulator-pod
spec:
    containers:
    - name: event-simulator
      image: [image]
    - name: image-processor
      image: some-image-processor
```