# kdump feature switch for Container Optimized OS in Kubernetes Engine

This is a recipe for enabling/disabling kdump feature in Kubernetes Engine.

On a Kubernetes Engine cluster with COS image (>= M73) as the nodes, you can run the following command to enable kdump feature:

```shell
kubectl apply -f https://raw.githubusercontent.com/xueweiz/scripts/master/cos-kdump-switch/enable-daemonset.yaml
```

Or to disable kdump feature:
```shell
kubectl delete -f https://raw.githubusercontent.com/xueweiz/scripts/master/cos-kdump-switch/enable-daemonset.yaml
kubectl apply -f https://raw.githubusercontent.com/xueweiz/scripts/master/cos-kdump-switch/disable-daemonset.yaml
```

This switch does the following:

1. Enable/disable the kdump feature by running "kdump_helper enable"/"kdump_helper disable".
2. Reboot the machine to update kernel commandline parameter if needed.
8. Sleep forever (DaemonSets do not support run to completion)
