# Kubernetes Ingress
## What is it?
- Ingress is a Kubernetes object used to manage external HTTP/HTTPS traffic into your cluster.
- It is a small entry point for web traffic
- It lets users access apps with normal URLs like:
```
https://myonlinestore.com
https://myonlinestore.com/watch
https://watch.myonlinestore.com
```
- Instead of using:
```
http://node-ip:30080
```

## Why do we use ingress?
- Without Ingress, you may expose each app using seperate NodePort or LoadBalancer Services.
- That can become messy and expensive.
- Example:
```
app1 -> LoadBalancer 1
app2 -> LoadBalancer 2
app3 -> LoadBalacner 3
```
- With Ingress, you can use one external entry point and route traffic to many internal Services.