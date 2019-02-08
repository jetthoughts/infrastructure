# Kuebrnetes on AWS

This is a example how to use modules to setup a HA kubernetes cluster.


```shell
$ terraform apply -auto-approve -target="module.k8s_master.null_resource.bootstrap_public[0]"
$ terraform apply -auto-approve -target="module.k8s_master.null_resource.bootstrap_public"
$ terraform apply -auto-approve -target="module.k8s_master.aws_route53_record.api"
```

Rebuild one of the masters:

```shell
$ terraform plan -target="module.k8s_master.null_resource.bootstrap_public[0]"  -target="module.k8s_master.aws_instance.masters[0]"
```
