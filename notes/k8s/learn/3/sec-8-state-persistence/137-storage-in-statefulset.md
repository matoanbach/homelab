# Storage in statefulSet
- statefulset-definition.yml
```yml
apiVersion: apps/v1
kind: StatefulSet
metadata:
    name: mysql
    labels:
        app: mysql
spec:
    template:
        metadata:
            labels:
                app: mysql
        spec:
            containers:
            - name: mysql
              image: mysql
    replicas: 3
    selector:
        matchLabels:
            app: mysql
    serviceName: mysql-h
    podManagementPolicy: Parallel
    volumeClaimTemplates:
    - metadata:
        name: data-volume
      spec:
        accessModes:
        - ReadWriteOnce
        sstorageClassName: google-storage
        resources:
            requests:
                storage: 500Mi
```

- sc-definition.yml
```yml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
    name: google-storage
provisioner: kubernetes.io/gce-pd
```
