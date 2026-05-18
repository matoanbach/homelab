# Persistent Volume
- pv-definition.yaml
```yml
apiVersion: v1
kind: PersistentVolume
metadata:
    name: pv-vol1
spec:
    accessModes:
    - ReadWRiteOnce
    #- ReadOnlyMany
    #- ReadWriteMany
    capacity:
        storage: 1Gi
    awsElasticBlockSstore:
        volumeID: <volume-id>
        fstype: ext4
```