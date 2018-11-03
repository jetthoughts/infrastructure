## Development
- http://blog.kubernetes.io/2017/05/draft-kubernetes-container-development.html
- https://github.com/kubernetes/minikube

## Distributed FS
- https://rook.io/
- https://www.minio.io/

## DB
- https://www.cockroachlabs.com/

## Networking
- https://www.vpn.net/

## Setup Hosts
- https://www.raspberrypi.org/blog/pi-3-booting-part-ii-ethernet-all-the-awesome/
- https://fai-project.org/fai-guide/
- http://www.projectatomic.io/blog/2015/06/creating-a-simple-bare-metal-atomic-host-cluster/
- http://www.projectatomic.io/
- http://cockpit-project.org/

# Terraform Usage

## Interactive Graph

```shell
$ docker run --cap-add=SYS_ADMIN -it --rm -p 5000:5000 -v $(pwd):/workdir:ro 28mm/blast-radius --serve clusters/kubernetes
```
