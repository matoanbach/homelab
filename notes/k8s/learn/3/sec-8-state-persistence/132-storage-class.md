# Storage Class
- sc-definition.yaml
```yml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
    name: google-storage
provisioner: kubernetes.io/gce-pd
```

- pvc-definition.yml
```yml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
    name: myclaim
spec:
    accessModes:
    - ReadWriteOnce
    storageClassName: google-storage
    resources:
        requests: 
            storage: 500Mi
```

- pod-definition.yml
```yml 
apiVersion: v1
kind: Pod
metadata:
    name: random-number-generator
spec:
    containers:
    - image: alpine
      name: alpine
      command: ["/bin/sh", "-c"]
      args: ["shuf -i 0-100 -n 1 >> /opt/number.out;"]
      volumeMounts:
      - name: data-volume
        mountPath: /opt
    volumes:
    - name: data-volume
      persistentVolumeClaim:
        claimName: myclaim
```