## With a scheduler

```yaml
apiVersion: v1
kind: Pod
metadata:
    name: nginx
    labels:
        name: nginx
spec:
    container:
    - name: nginx
      image: nginx
      ports:
      - containerPort: 8080
    nodeName: node02
```

## Without a Scheduler
- create a binding request
```yaml
apiVersion: v1
kind: Binding
metadata:
    name: nginx
target:
    apiVersion: v1
    kind: Node
    name: node02
```
- run
```bash
curl --header "Content-Type:application/json" \
  --request POST \
  --data '{"apiVersion":"v1", "kind":"Binding", ... }' \
  http://$SERVER/api/v1/namespaces/default/pods/$PODNAME/binding/
```