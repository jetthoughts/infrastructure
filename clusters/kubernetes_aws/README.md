## How to build basic cluster



```shell
$ export TF_VAR_version=`date +v%Y%m%d`
$ terraform apply -target=aws_autoscaling_group.k8s-master-$TF_VAR_version # Should create at least one node of master
$ terraform apply # DNS for the master instance, download certificates. Setup Nodes.
$ kubectl get no  # Verify that we see Master node
$ openssl pkcs12 -export -clcerts -inkey assets/kubecfg.key -in assets/kubecfg.crt -out assets/kubecfg.p12 -name "kubernetes-client-virginia"
```

Next steps go to the [k8s-tasks](../../k8s-tasks/README.md)

# Refernces:

- [Installing Kubernetes on Linux with kubeadm](https://kubernetes.io/docs/getting-started-guides/kubeadm/)
- [Setup K8S v1.6.0-rc.1 cluster](https://jtway.co/setup-k8s-v1-6-0-rc-1-cluster-b4cc7749973f)
- [Kubernetes 1.6.1 Authentication via Google](https://jtway.co/kubernetes-auth-google-with-rbac-60a74787e6a5)
