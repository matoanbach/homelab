## Metrics Server - Getting Started
- minikube - run `minikube addons enable metrics-server`
- others - run `git cline https://github.com/kubernetes-sigs/metrics-server.git`
- `kubectl create -f deploy/1.8+/`

## Viewing Metrics
```bash
kubectl top node
kubectl top pod
```