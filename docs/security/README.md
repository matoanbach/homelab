# Security Hardening

## Purpose

Security hardening adds guardrails after the base platform is working.

## Scope For This Project

This is not one install step. It is a set of changes applied in phases.

Recommended first pass:

1. Pod Security Admission
2. NetworkPolicies
3. service account and RBAC cleanup
4. image scanning in CI
5. ingress and secret review

## Why It Is Needed

- reduces accidental over-permissioning
- limits east-west traffic
- catches obvious image and runtime risks earlier

## Prerequisites

- apps are already deployed
- ingress, secrets, and CI are already working

## Install Method

This area is mostly plain YAML and policy, not Helm.

- write `NetworkPolicy` and namespace labels directly
- change RBAC and service accounts directly
- add scanners to the CI pipeline rather than installing a cluster chart first

## Installation

There is no single install command for this section.

Roll security controls out in small steps after the base platform is stable.

## Configuration

Configuration in this phase means:

- labeling namespaces for Pod Security Admission
- writing namespace-specific `NetworkPolicy` objects
- tightening service account and RBAC usage per workload
- adding CI scanning rules and thresholds

## Step 1: Pod Security Admission

Apply Pod Security labels to application namespaces.

Example:

```bash
kubectl label namespace apps \
  pod-security.kubernetes.io/enforce=baseline \
  pod-security.kubernetes.io/audit=restricted \
  pod-security.kubernetes.io/warn=restricted
```

## Step 2: Default-Deny NetworkPolicy

Because this cluster uses Calico, NetworkPolicies are supported.

Example default deny policy:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
  namespace: apps
spec:
  podSelector: {}
  policyTypes:
    - Ingress
    - Egress
```

Then add explicit allow policies for DNS, ingress traffic, and app dependencies.

## Step 3: RBAC And Service Accounts

- avoid using the default service account for real apps
- grant only the permissions each workload actually needs
- remove broad cluster-admin bindings outside admin workflows

## Step 4: Image Scanning In CI

Add Trivy or a similar scanner in Jenkins before image push or deployment.

## Step 5: Review Exposed Surfaces

- make sure public routes go through ingress intentionally
- keep TLS enabled everywhere public
- keep raw secrets out of Git

## Verification

- deploy a test pod and confirm Pod Security labels behave as expected
- confirm denied traffic stays denied with network policies
- confirm CI fails on severe image issues once scanning is enabled

## Troubleshooting

- If apps break after default-deny, add DNS and dependency allow rules first.
- If namespaces fail admission, inspect the pod security context fields.
- Roll hardening out namespace by namespace, not all at once.

## Notes For This Cluster

- Add hardening after the base platform is stable.
- Calico support makes NetworkPolicy a strong first security control here.
- Start with `baseline` and tighten toward `restricted` where workloads allow it.

## Reference

- https://kubernetes.io/docs/concepts/services-networking/network-policies/
- https://kubernetes.io/docs/concepts/security/pod-security-standards/
