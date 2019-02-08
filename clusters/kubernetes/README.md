# Kuebrnetes on AWS

This is a example how to use modules to setup a HA kubernetes cluster.


```
$ terraform apply -auto-approve -target="module.k8s_master.aws_instance.masters"
$ terraform apply -auto-approve -target="module.k8s_master.aws_route53_record.api"
```
