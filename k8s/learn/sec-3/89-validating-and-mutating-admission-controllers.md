## Configuring Admission Webhook

<img src="https://github.com/matoanbach/homelab/blob/main/images/89.1.png"/>

```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingWebhookconfiguration
metadata:
    name: "pod-policy.example.com"
webhooks:
- name: "pod-policy.example.com"
  clientConfig:
    service:
        namespace: "webhook-namespace"
        name: "webhook-service"
    caBundle: "acASDs8D023c...sdaAKHga"
  rules:
  - apiGroups: [""]
    apiVersions: ["v1"]
    operations: ["CREATE"]
    resources: ["pods"]
    scope: "Namespaced"
```