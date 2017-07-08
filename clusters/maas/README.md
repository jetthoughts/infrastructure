# Maas on RaspberryPi 3

## Setup Ubuntu

1. Download and burn image Ubuntu Classic Server from https://ubuntu-pi-flavour-maker.org/download/
2. Upgrade packages and setup WiFi step by step:

```shell
$ terraform apply -target=null_resource.upgrade-packages -var 'server_ip=10.0.0.1'
$ terraform apply -target=null_resource.set-hostname -var 'server_ip=10.0.0.1' -var 'server_hostname=maas'
$ terraform apply -target=null_resource.wifi -var 'server_ip=10.0.0.1' -var 'wlan_ssid=FreeWiFi' -var 'wlan_psk=ChangeMe'
$ terraform apply -target=null_resource.zram -var 'server_ip=10.0.0.1'
```

## Install Maas packages

```shell
$ terraform apply -target=null_resource.maas-packages -var 'server_ip=10.0.0.1 
$ terraform apply -target=null_resource.maas-admin -var 'server_ip=10.0.0.1 
$ terraform apply -target=null_resource.maas-eth-network -var 'server_ip=10.0.0.1 
```
