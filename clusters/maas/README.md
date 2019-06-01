# Maas on RaspberryPi 3

## Setup Ubuntu

1. Download and burn image Ubuntu Classic Server from https://www.ubuntu.com/download/iot/raspberry-pi-2-3
1. Detect ip address from local network: `nmap -sn 10.0.0.0/24`
1. Update current password to new one:
    ```shell
    $ ssh ubuntu@<ip>
    ubuntu@<ip>'s password: ubuntu

    (current) UNIX password:
    Enter new UNIX password:
    Retype new UNIX password:
    passwd: password updated successfully
    ```
1. Allow authorize via ssh private key:
    ```shell
    $ ssh-copy-id ubuntu@<ip>
    ...
    ```
1. Create a new file `terraform.tfvars` and specify new values:
    - `server_ip = "<ip>"`
    - `server_hostname = maas`
    - `wlan_psk = "<WiFi password>"`
    - `wlan_ssid = "<WiFi name>"`
   otherwise use `-var` argument as shown bellow.

1. Upgrade packages and setup WiFi step by step:
    ```shell
    $ terraform apply -target=null_resource.packages   -auto-approve -var 'server_ip=10.0.0.1'
    $ terraform apply -target=null_resource.hostname   -auto-approve -var 'server_ip=10.0.0.1' -var 'server_hostname=maas'
    $ terraform apply -target=null_resource.wifi       -auto-approve -var 'server_ip=10.0.0.1' -var 'wlan_ssid=FreeWiFi'   -var 'wlan_psk=ChangeMe'
    $ terraform apply -target=null_resource.zram       -auto-approve -var 'server_ip=10.0.0.1'
    $ : Optional you can install netdata monitoring tool
    $ terraform apply -target=null_resource.monitoring -auto-approve -var 'server_ip=10.0.0.1'
    ```
1. Detect a new IP that attached to WiFi and replace it in `terraform.tfvars` for `server_ip` variable

## Install Maas packages

```shell
$ terraform apply -target=null_resource.maas-packages -var 'server_ip=10.0.0.1'
$ terraform apply -target=null_resource.maas-admin -var 'server_ip=10.0.0.1'
$ terraform apply -target=null_resource.maas-eth-network -var 'server_ip=10.0.0.1'
```

## Install Maas Node

- Flash SD card https://ubuntu-pi-flavour-maker.org/download/
- Boot and click 0 to enable U-Boot menu
- Get the Ethernet mac addrs
- Run commands:

```
device_tree_address=0x02008000
dhcp
pxe get
pxe boot
```

### Check DHCPD

```
sudo tcpdump -i eth0 port bootpc -v
```
