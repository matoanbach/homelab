# Jobs
## Restart Policy
- pod-definition.yml
```yml
apiVersion: v1
kind: Pod
metadata:
    name: math-pod
spec:
    containers:
    - name: math-add
      image: ubuntu
      command: ['expr', '3', '+', '2']
    restartPolicy: Never
```

## Job
- job-definition.yml
```yml
apiVersion: batch/v1
kind: Job
metadata:
    name: math-add-job
spec:
    complettions: 3
    parallelism: 3
    template:
        spec:
            containers:
            - name: math-add
              image: ubuntu
              command: ['expr', '3', '+', '2']
        restartPolicy: Never
```