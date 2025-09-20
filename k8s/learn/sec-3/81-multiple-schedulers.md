## Multi scheduling
```bash
apiVersion: kuberscheduler.config.k8s.io/v1
kind: KubeSchedulerConfiguration
profiles:
- schedulerName: my-scheduler-2
```

```bash
apiVersion: kuberscheduler.config.k8s.io/v1
kind: KubeSchedulerConfiguration
profiles:
- schedulerName: my-scheduler
```

```bash
apiVersion: kuberscheduler.config.k8s.io/v1
kind: KubeSchedulerConfiguration
profiles:
- schedulerName: default-secheduler
```

## Deploying an Additional Scheduler
```bash
ExecStart=/usr/local/bin/kube-scheduler \\
    --config=/etc/kubernetes/config/kube-scheduler.yaml
```

## Deploying an Addition Scheduler as a Pod
```yaml
apiVersion: v1
kind: Pod
metadata:
    name: my-custom-scheduler
    namespace: kube-system
spec:
    containers:
    - command:
        - kube-scheduler
        - --address=127.0.0.1
        - --kubeconfig=/etc/kubernetes/scheduler.conf
        - --config=/etc/kubernetes/my-scheduler-config.yaml
        image: k8s.grc.io/kube-scheduler-amd64:v1.XX.X
        name: kube-scheduler
```

- my-scheduler-config.yaml
```yaml
apiVersion: kubescheduler.config.k8s.io/v1
kind: KubeSchedulerConfiguration
profiles:
- schedulerName: my-scheduler
leaderElection:
    leaderElect: true
    resourceNamespace: kube-system
    resouceName: lock-object-my-scheduler
```

## Custom Scheduler for pods
```yaml
apiVersion: v1
kind: Pod
metadata:
    name: nginx
spec:
    containers:
    - name: nginx
      image: nginx
    schedulerName: my-custom-scheduler

```