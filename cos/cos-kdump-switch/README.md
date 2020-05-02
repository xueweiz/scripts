# kdump feature switch for Container Optimized OS (COS) in Kubernetes

This is a recipe for enabling/disabling the COS kdump feature in Kubernetes.

On a Kubernetes cluster with COS image (>= M73) as the nodes, you can run the following command to enable kdump feature:

```shell
kubectl apply -f cos-enable-daemonset.yaml
```

Or to disable kdump feature:
```shell
kubectl delete -f cos-enable-daemonset.yaml
kubectl apply -f cos-disable-daemonset.yaml
```

This switch does the following:

1. Enable/disable the kdump feature by running "kdump_helper enable"/"kdump_helper disable".
2. Reboot the machine to update kernel commandline parameter if needed.
3. Sleep forever (DaemonSets do not support run to completion)
