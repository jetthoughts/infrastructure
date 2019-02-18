# Provision

```shell
$ ./bin/bootstrap
```

# Access

Modify admin config or copy to `~/.kube/config.yaml` with correct domain name.


```shell
$ kubectl --kubeconfig ./assets/staging/admin.conf get no -o wide
```

Where `staging` is the cluster name.
