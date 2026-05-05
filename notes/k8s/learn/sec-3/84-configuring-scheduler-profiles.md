## Scheduler Extension Points

| Phase            | Extension Points                        | Built-in Plugins                           |
|------------------|-----------------------------------------|--------------------------------------------|
| Scheduling Queue | `queueSort`                             | PrioritySort                               |
| Filtering        | `preFilter`, `filter`, `postFilter`     | NodeResourcesFit, NodeName, NodeUnschedule |
| Scoring          | `preScore`, `score`, `reserve`          | NodeResourcesFit, ImageLocality            |
| Binding          | `permit`, `preBind`, `bind`, `postbind` | DefaultBinder                              |

## Scheduler Profiles in YAMl
```bash
apiVersion: kubescheduler.config.k8s.io/v1
kind: KubeSchedulerConfiguration
profiles:
- schedulerName: my-scheduler-2
  plugins:
    score:
        disabled:
        - name: TaintToleration
        enabled:
        - name: MyCustomPluginA
        - name: MyCustomPluginB
- schedulerName: my-scheduler-3
  plugins:
    preScore:
        disabled:
        - name: '*'
    score:
        disabled:
        - name: '*'
- schedulerName: my-scheduler-4
```