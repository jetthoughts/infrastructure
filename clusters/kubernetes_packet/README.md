# Kubernetes on Packet

## API

1. Create account
2. Generate API token
3. Create a project. For organizations you need manual create a project and update the state file.

```bash
$ terraform apply -target=packet_project.k8s_dev
```

4. Generate SSH keys

```bash
$ ssh-keygen -f assets/k8s -C "miry.sof@gmail.com"
```

5. Create one master

```bash
$ terraform apply -target=packet_device.masters
```
