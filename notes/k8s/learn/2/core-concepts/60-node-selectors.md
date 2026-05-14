# Node Selector
## What is it?
- A node selector is a simple way to tell Kubernetes that:
> "Run this pod only on nodes with this label"

- It is used inside Pod spec:
```yml
spec:
    nodeSelector:
        size: large
```