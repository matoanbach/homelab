# Service
## NodePort
```yml
apiVersion: v1
kind: Service
metadata:
    name: myapp-service

spec:
    type: NodePort
    ports:
      - targetPort: 80
        port: 80
        nodePort: 30008
    
    selector:
        app: myapp
        type: front-end
```

## ClusterIP Service
### Backend deployment
- Deployment.yml
```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-deployment
spec:
  replicas: 2

  selector:
    matchLabels:
      app: backend

  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
        - name: backend
          image: my-backend-image:latest
          ports:
            - containerPort: 8080
```

- Service.yml
```yml
apiVersion: v1
kind: Service
metadata:
  name: backend-service
spec:
  type: ClusterIP

  selector:
    app: backend

  ports:
    - name: http
      protocol: TCP
      port: 80
      targetPort: 8080
```

### Frontend deployment
```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend-deployment
spec:
  replicas: 2

  selector:
    matchLabels:
      app: frontend

  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
        - name: frontend
          image: my-frontend-image:latest
          ports:
            - containerPort: 3000
          env:
            - name: BACKEND_URL
              value: "http://backend-service"
```

## LoadBalancer
```yml
apiVersion: v1
kind: Service
metadata:
    name: myapp-service
spec:
    type: LoadBalancer
    ports:
      - targetPorts:
        port: 80
        nodePort: 30008
```