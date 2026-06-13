# Monitoring

## Purpose

Monitoring provides cluster and application metrics, dashboards, and alerting.

## Recommended First Choice

Use `kube-prometheus-stack`.

## Why It Is Needed

- Shows node and pod health
- Tracks CPU, memory, restarts, and cluster status
- Adds Grafana for dashboards

## Prerequisites

- Working cluster
- Enough CPU and memory for a monitoring stack
- Storage if you want persistent Grafana or Prometheus data

## Install Method

This component should be installed with Helm.

- Helm manages Prometheus, Grafana, Alertmanager, exporters, and CRDs.
- We still own the values file, dashboard access pattern, and any extra scrape configuration.

## Installation

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace
```

## Configuration

For this cluster, expect to create a custom values file soon to reduce retention and tune requests.

## First Access

Port-forward Grafana:

```bash
kubectl -n monitoring port-forward svc/monitoring-grafana 3000:80
```

Get the admin password:

```bash
kubectl -n monitoring get secret monitoring-grafana -o jsonpath='{.data.admin-password}' | base64 -d
```

## Verification

```bash
kubectl get pods -n monitoring
kubectl get svc -n monitoring
```

Expected result:

- Prometheus, Grafana, and node exporter pods are `Running`
- Grafana opens locally through the port-forward

## Troubleshooting

- If pods stay pending, reduce resource requests and check storage.
- If Grafana has no data, confirm Prometheus targets are healthy.
- If the stack is too heavy, disable or tune optional pieces before adding more apps.

## Notes For This Cluster

- This cluster is small, so tuning matters.
- Start with short retention and modest resource requests.
- Add ingress or tunnel access for Grafana only after the stack is stable.

## Reference

- https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack
