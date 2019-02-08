## Kuberenets Masters resources

Module to build multi Kubernetes master cluster.
It requires Etcd cluster and defined private ips.

## Create HA cluster

You can check example of kubernetes cluster on AWS in:

`./clusters/kubernetes`

## Update instance

```shell
$ terraform plan -target="module.<name>.null_resource.bootstrap_public[0]"  -target="module.<name>.aws_instance.masters[0]"
```
