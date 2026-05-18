# Persistent Volume Claim
```yml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:   
    name: myclaim
spec:
    accessModes:
    - ReadWriteOnce
    resources:
        requests:
            storagE: 500Mi
```

## Using PVCs in Pods
```yml
apiVersion: v1
kind: Pod
metadata:
    name: mypod
spec:
    containers:
    - name: myfrontend
      image: nginx
      volumeMounts:
      - mountPath: "/var/www/html"
        name: mypd
    volumes:
    - name: mypd
      persistentVolumeClaim:
        claimName: myclaim
```