### Sample Application

```shell
$ kubectl apply -f busybox.yaml
$ kubectl exec busybox -- nslookup kubernetes
Server:    10.96.0.10
Address 1: 10.96.0.10 kube-dns.kube-system.svc.cluster.local

Name:      kubernetes
Address 1: 10.96.0.1 kubernetes.default.svc.cluster.local
```

[More Info](https://kubernetes.io/docs/tasks/debug-application-cluster/get-shell-running-container/)


```shell
$ kubectl run hello-world --replicas=5 --labels="run=load-balancer-example" --image=gcr.io/google-samples/node-hello:1.0  --port=8080
```
### External DNS

```shell
$ # Updated DNSMASQ manifest/config
$ kubectl apply -f kube-system/config_dns.yaml

$ # Restart DNS pod
$ kubectl -n kube-system get po -o wide # get current DNS pod name
$ kubectl -n kube-system delete po kube-dns-changeme
$ kubectl -n kube-system get po -o wide # Wait until a new DNS pod start
$ kubectl -n kube-system logs kube-dns-new-pod-name dnsmasq

$ # Verify that it works
$ kubectl exec busybox -- nslookup nginx.service.consul
Server:    10.96.0.10
Address 1: 10.96.0.10 kube-dns.kube-system.svc.cluster.local

Name:      nginx.service.consul
Address 1: 10.0.8.140 ip-10-0-8-140.ec2.internal
Address 2: 10.0.8.217 ip-10-0-8-217.ec2.internal
Address 3: 10.0.8.76 ip-10-0-8-76.ec2.internal

$ kubectl exec busybox -- wget -O /dev/stdout nginx.service.consul:80
```

### Sample Web Application/Service

```shell
$ kubectl apply -f web.yaml
$ kubectl exec busybox -- nslookup web.default.svc.cluster.local
Server:    10.96.0.10
Address 1: 10.96.0.10 kube-dns.kube-system.svc.cluster.local

Name:      web
Address 1: 10.107.76.218 web.default.svc.cluster.local
$ kubectl exec busybox -- wget -O /dev/stdout web.default.svc.cluster.local

$ # open https://api.internal.virginia.kb.pubnative.net:6443/api/v1/namespaces/default/services/web/proxy
```

### Kubernetes UI

- [Kubernetes RBAC Documentation](https://kubernetes.io/docs/admin/authorization/rbac/)
- [Kubernetes UI Deployment](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/#deploying-the-dashboard-ui)

```shell
$ kubectl create -f kube-system/kubernetes-dashboard.yaml
$ open https://api.internal.virginia.kb.pubnative.net:6443/ui
```

### Monitoring

- [Documentation]()
- [Heapster with Influxdb](https://github.com/kubernetes/heapster/blob/master/docs/influxdb.md)

```shell
$ kubectl create -f kube-system/heapster-rbac.yaml
$ kubectl create -f kube-system/influxdb.yaml
$ kubectl create -f kube-system/grafana.yaml
$ kubectl create -f kube-system/heapster.yaml
```

Or Use recent changes from the Heapster repo:

```shell
$ cd ~/projects/
$ git clone git@github.com:kubernetes/heapster.git
$ cd heapster
$ kubectl create -f deploy/kube-config/rbac/heapster-rbac.yaml
$ # Edit yaml files to be available
$ kubectl create -f deploy/kube-config/influxdb
```

After setup in the Kubernetes UI we should get metrics and charts. And new services should appear:

```
$ kubectl cluster-info
Kubernetes master is running at https://10.0.10.87:6443
Heapster is running at https://10.0.10.87:6443/api/v1/proxy/namespaces/kube-system/services/heapster
KubeDNS is running at https://10.0.10.87:6443/api/v1/proxy/namespaces/kube-system/services/kube-dns
monitoring-grafana is running at https://10.0.10.87:6443/api/v1/proxy/namespaces/kube-system/services/monitoring-grafana
monitoring-influxdb is running at https://10.0.10.87:6443/api/v1/proxy/namespaces/kube-system/services/monitoring-influxdb
$ open https://10.0.10.87:6443/api/v1/proxy/namespaces/kube-system/services/monitoring-grafana/dashboard/db/cluster
```
