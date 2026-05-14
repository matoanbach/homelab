# Taints and Tolerations
## What are they
- Taints are rules placed on nodes
- Tolerations are permissions placed on pods.
- Simple definitions:
    > Taint: Node says "do not come here unless allowed"
    > Toleration: Pod says "I am allowed to run there"
## Why do we use them?
- We use them to control which pods can run on which nodes

## How to use them
- kubectl taint nodes node1 app=blue:NoSechedule
- Then a pod needs a matching toleration:
```yml
tolerations:
- key: "app"
  operator: "Equal"
  value: "blue"
  effect: "NoSchedule"
```

## How many kinds are there?
- There are 3 tain effects:

|Effect|Meaning|
| -- |-- |
|NoSchedule|Do not schedule new pods unless they tolerate the taint|
|PreferNoSchedule|Try to avoid scheduling Pods there, but not guaranteed|
|NoExecute|Do no schedule new pods, and evict existing pods that do not tolerate the taint|