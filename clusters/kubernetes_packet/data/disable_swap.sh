#!/bin/bash -xe

swapoff -a
sudo sed -i.bak '/swap/ s/^\(.*\)$/#\1/g' /etc/fstab
