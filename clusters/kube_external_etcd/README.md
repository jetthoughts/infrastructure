# Provision

First need to update own variables in `terraform.tfvars`, example:

```
admin_email = "miry.sof@gmail"
google_oauth_client_id = "xxxxx.apps.googleusercontent.com"
kubeadm_bootstrap_token = "12123.1231231231"
dns_zone_id = "AAAAAAABBBB"
domain = "example.com"
master_addresses = ["10.0.0.4","10.0.0.5","10.0.0.6"]
cert_sans = ["ip-10-0-0-4.ap-northeast-1.compute.internal","ip-10-0-0-5.ap-northeast-1.compute.internal","ip-10-0-0-6.ap-northeast-1.compute.internal"]
etcd_endpoints = ["http://10.0.0.11:2379", "http://10.0.0.12:2379", "http://10.0.0.13:2379"]
vpc_id = "vpc-123123123123"
ami_id = "ami-121231231231"
availability_zone = "ap-northeast-1a"
subnet_id = "subnet-12312312312"
master_security_groups = ["sg-123123123", "sg-12312312"]
node_security_groups = ["sg-123123123", "sg-12312312"]
```

Then there is steps how to build cluster automaticaly:

```shell
$ ./bin/setup
```

# Access

Modify admin config or copy to `~/.kube/config.yaml` with correct domain name.


```shell
$ kubectl --kubeconfig ./assets/staging/admin.conf get no -o wide
```

Where `staging` is the cluster name.

# Clean

Remove all AWS resources and clean ETCD prefix.

```shell
$ ./bin/clean
```
