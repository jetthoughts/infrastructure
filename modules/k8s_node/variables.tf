variable "name" {
  default = "staging"
}

variable "kube_version" {
  default = "v1.11.2"
}

variable "node_labels" {
  type    = "list"
  default = []
}

variable "availability_zone" {
  default = "us-east-1a"
}

variable "subnet_id" {}

variable "master_ip" {
  description = "The private ip of kubernetes master"
}

variable "image_id" {}

variable "instance_type" {
  default = "t2.small"
}

variable "ebs_optimized" {
  default = false
}

variable "ssh_key_name" {}

variable "security_groups" {
  type = "list"
}

variable "bootstrap_token" {
  description = "Kubeadm token. Generate a new token: `kubeadm token`"
}

variable "spot_price" {
  description = "If empty used Demand instances"
  default     = 0
}

variable "min_size" {
  description = "Minimum number of instances"
  default     = "1"
}

variable "max_size" {
  description = "Minimum number of instances"
  default     = "1"
}

variable "tags" {
  type        = "list"
  description = "AutoScaling tags"

  default = [
    {
      key                 = "Terraform"
      value               = "true"
      propagate_at_launch = true
    },
  ]
}

variable "target_group_arns" {
  type        = "list"
  description = "Attach instances to target group"

  default = []
}

variable "pre_init_script" {
  description = "Content to be run before the kubeadm."
  default     = ""
}

variable "kube_node_taints" {
  type        = "list"
  description = "List of taints to apply to this group of nodes"
  default     = []
}

variable "kubelet_extra_args" {
  type        = "list"
  description = "List of kubelet args"

  default = [
    "--cloud-provider=aws",
    "--runtime-cgroups=/systemd/system.slice",
    "--kubelet-cgroups=/systemd/system.slice",
  ]
}

variable "root_volume_size" {
  description = "Set root volume disk size"
  default     = "20"
}
