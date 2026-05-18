# Ingress Networking
## Ingress Controller
```yml
apiVersion: apps/v1
kind: Deployment
metadata:
    name: nginx-ingress-controller
spec:
    replicas: 1
    selector:
        matchLabels:
            name: nginx-ingress
    template:
        metadata:
            labels:
                name: nginx-ingress
        spec:
            containers:
                - name: nginx-ingress-controller
                  image: quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.21.0
                  args:
                    - /nginx-ingress-controller
                    - --configmao-$(POD_NAMESPACE)/nginx-configuration
                  env:
                    - name: POD_NAME
                      valueFrom:
                        fieldRef:
                          fieldPath: metadata.name
                    - name: POD_NAMESPACE
                      valuefrom:
                        fieldRef:
                          fieldPath: metadata.namespace
                  ports:
                    - name: http
                      containerPort: 80
                    - name: https
                      containerPort: 443

```
- ingress controller service
```yml
apiVersion: v1
kind: Service
metadata:
    name: nginx-ingress
spec:
    type: NodePort
    ports:
    - port: 80
      targetPort: 80
      protocol: TCP
      name: http
    - port: 443
      targetPort: 443
      protocol: TCP
      name: https
    selector:
      name: nginx-ingress
```
- ConfigMap
```yml
kind: ConfigMap
apiVersion: v1
metadata:
    name: nginx-configuration
```
- Auth
```yml
apiVersion: v1
kind: ServiceAccount
metadata:
    name: nginx-ingress-serviceaccount
```

## Ingress Resource
```yml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-wear-watch
spec:
  rules:
  - http:
      paths:
      - path: /wear
        backend:
          service:
            name: wear-service
            port: 80
      - path: /watch
        backend:
          service:
            name: watch-service
            port: 80 
```

```yml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-wear-watch
spec:
  rules:
  - host: wear.my-online-store.com
    http:
      paths:
      - path: /wear
        backend:
          service:
            name: wear-service
            port: 80
  - host: watch.my-online-store.com
    http:
      paths:
      - path: /watch
        backend:
          service:
            name: watch-service
            port: 80
```