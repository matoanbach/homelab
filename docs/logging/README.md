# Logging

## Purpose

Logging lets you search application and cluster logs during debugging and operations.

## Recommended First Choice

Use Loki with Promtail.

## Why It Is Needed

- Centralizes pod logs
- Integrates well with Grafana
- Is lighter than running Elasticsearch and Kibana on this cluster

## Prerequisites

- Monitoring stack optional but recommended, because Grafana can query Loki
- Storage if you want retained logs beyond short-term testing

## Install Method

This component should be installed with Helm.

- Helm manages Loki and Promtail.
- We still own the values files, retention settings, and Grafana data source wiring.

## Deployment Mode

For this cluster, start with a small monolithic Loki deployment, not a multi-component high-availability setup.

## Installation

```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm install loki grafana/loki --namespace logging --create-namespace
helm install promtail grafana/promtail --namespace logging
```

## Configuration

Start with small values and keep the deployment simple:

- monolithic Loki
- short retention
- minimal storage expectations until Longhorn is proven stable

## Verification

```bash
kubectl get pods -n logging
kubectl get svc -n logging
```

Expected result:

- Loki and Promtail pods are `Running`
- new app logs appear in Loki queries from Grafana

## Grafana Integration

If Grafana from `kube-prometheus-stack` is already running, add Loki as a data source and test a simple query such as:

```text
{namespace="apps"}
```

## Troubleshooting

- If no logs appear, confirm Promtail is running on the nodes and can reach Loki.
- If Loki is unstable, lower retention and start with minimal storage expectations.
- If dashboards work but logs do not, check the Loki data source URL inside Grafana.

## Notes For This Cluster

- Keep retention short at first.
- Start with one small workload and verify end-to-end log flow before expanding.
- Revisit storage and retention after the platform is otherwise stable.

## Reference

- https://grafana.com/docs/loki/latest/setup/install/helm/
