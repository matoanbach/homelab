# ENV
```yml
env:
    - name: APP_COLOR
      value: pink

env:
    - name: APP_COLOR
      valueFrom:
        configuMapKeyRef:

env:
    - name: APP_COLOR
      valueFrom:
        secretKeyRef:
```