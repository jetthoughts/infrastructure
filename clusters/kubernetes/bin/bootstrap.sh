#!/usr/bin/env bash

set -e
set -x

cluster="k8s-test"
region="us-east-1"

aws ec2 describe-instances --region $region \
                           --filters 'Name=tag-key,Values=Cluster' "Name=tag-value,Values=${cluster}" 'Name=instance-state-name,Values=running' \
                           --query "Reservations[*].Instances[*].[PrivateDnsName,Tags[?Key=='Role']| [0].Value]" \
                           --output table

echo "Destroy old masters..."
TF_VAR_masters_count=0 terraform apply -target=module.k8s_master.aws_instance.masters

echo "Build new master..."
export TF_VAR_version=`date +v%Y%m%d`
TF_VAR_masters_count=1 terraform apply -target=module.k8s_master.aws_instance.masters

echo "Download new certificates..."
terraform taint -module=k8s_master null_resource.download-ca-certificate
TF_VAR_masters_count=1 terraform apply -target=module.k8s_master.null_resource.download-ca-certificate

echo "Spinoff new masters..."
terraform apply -target=module.k8s_master.aws_instance.masters

aws ec2 describe-instances --region $region \
                           --filters 'Name=tag-key,Values=Cluster' "Name=tag-value,Values=${cluster}" 'Name=instance-state-name,Values=running' \
                           --query "Reservations[*].Instances[*].[PrivateDnsName,Tags[?Key=='Role']| [0].Value]" \
                           --output table

echo "Rebuilding slaves..."
terraform apply -target=module.k8s_node.aws_autoscaling_group.node -target=module.k8s_node.aws_launch_configuration.node

echo "Destroy old slaves..."
for i in $(aws ec2 describe-instances --region $region --filters 'Name=tag-key,Values=Cluster' "Name=tag-value,Values=${cluster}" 'Name=tag-key,Values=Role' "Name=tag-value,Values=k8s-node" 'Name=instance-state-name,Values=running' --query 'Reservations[].Instances[].InstanceId' --output text)
do
    echo $i
    aws ec2 terminate-instances --instance-ids $i
done
