## Install `etcd`
1. Install the binaries
2. Extract
```bash
tar xzvf etcd-...tar.gz
```
3. Run `etcd` service
```bash
./etcd # port 2379 is the default one
```
- Run etcd cuddle
```bash
etcdctl put key1 value1
```
- To retrieve data, run `./etcdctl get key1`

## set up - manual
- `wget -q --https-only [the etcd repository]`

## set up - kubeadm
- `kubectl get pods -n kube-system`

## Run inside the etcd-master pod
- `kubel exec etcd-master -n kube-system etcdctl get / --prefix -keys-only`

## ETCD - Commands (Optional)
- Version 2
    ```bash
    etcdctl backup
    etcdctl cluster-health
    etcdctl mk
    etcdctl mkdir
    etcdctl set
    ```
- Version 3
    ```bash
    etcdctl snapshot save 
    etcdctl endpoint health
    etcdctl get
    etcdctl put
    ```
- To set the right version of API set the environment variable ETCDCTL_API command `export ETCDCTL_API=3`. Otherwise, it will be version 2 by default.
- Apart from that, you must also specify path to certificate files so that ETCDCtl can authenticate to the ETCD API Server. The certificate files are available in the etcd-master at the following path. We discuss more about certificates in the security section of this course. So don't worrry if this looks complex:
    ```bash
    --cacert /etc/kubernetes/pki/etcd/ca.crt     
    --cert /etc/kubernetes/pki/etcd/server.crt     
    --key /etc/kubernetes/pki/etcd/server.key
    ```
- Below is the final form:
    ```bash
    kubectl exec etcd-master -n kube-system -- sh -c "ETCDCTL_API=3 etcdctl get / --prefix --keys-only --limit=10 --cacert /etc/kubernetes/pki/etcd/ca.crt --cert /etc/kubernetes/pki/etcd/server.crt  --key /etc/kubernetes/pki/etcd/server.key" 
    ```