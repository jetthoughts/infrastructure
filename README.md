# infrastructure
Contains sample recipes for DataCenter

# Cluster

## Provision hosts

Decided to use Maas as host provision tool.

## Manifesto

- We want fast deployments: each instance provision itself independently and immutable images are used
- We use existing provisioning tools: [Terraform](https://www.terraform.io/), [Packer](https://www.packer.io/), [Ansible](https://www.ansible.com/) and [kubeadm](http://kubernetes.io/docs/getting-started-guides/kubeadm)
- We avoid resources that are available only for a specific cloud provider
- We provision IaaS, PaaS and SaaS: lifting a distributed application should be possible with a few commands
