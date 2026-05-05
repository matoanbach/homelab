## Static Pods
```bash
ExecStart=/usr/local/bin/kubelet \\
    --container-runtime=remote \\
    --container-runtime-endpoint=unix:///var/run/containerd/containerd.sock \\
    --pod-manifest-path=/etc/kubernetes/manifests \\
    --kubeconfig=/var/lib/kubelet/kubeconfig \\
    --network-plugin=cni \\
    --register-node=true \\
    --v=2
```

```bash
staticPodPath: /etc/kubernetes/manifests
    --pod-manifest-path=/etc/kubernetes/manifests \\ # change to the below
    --config=kubeconfig.yaml \\
```