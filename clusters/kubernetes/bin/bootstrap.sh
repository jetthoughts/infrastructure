#!/usr/bin/env bash

set -e

cluster="k8s-test"

aws ec2 describe-instances --region us-east-1 \
                           --filters 'Name=tag-key,Values=Cluster' "Name=tag-value,Values=${cluster}" 'Name=instance-state-name,Values=running' \
                           --query "Reservations[*].Instances[*].[PrivateDnsName,Tags[?Key=='Role']| [0].Value]" \
                           --output table

echo "Rebuilding master..."
terraform apply -target=module.k8s_master.aws_autoscaling_group.master -target=module.k8s_master.aws_launch_configuration.master

# Destroy existing master
masterid=$(aws ec2 describe-instances --region us-east-1 --filters 'Name=tag-key,Values=Name' "Name=tag-value,Values=${cluster}" 'Name=instance-state-name,Values=running' --query 'Reservations[*].Instances[*].InstanceId' --output text)
aws ec2 terminate-instances --instance-ids $masterid

sleep 120
while [ "$(aws ec2 describe-instances --region us-east-1 --filters 'Name=tag-key,Values=Name' "Name=tag-value,Values=${cluster}" 'Name=instance-state-name,Values=running' --query 'Reservations[*].Instances[*].InstanceId' --output text)1" = "1" ]
do
  sleep 10
  date
done
