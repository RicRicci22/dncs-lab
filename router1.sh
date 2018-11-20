#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y tcpdump apt-transport-https ca-certificates curl software-properties-common --assume-yes --force-yes
wget -O- https://apps3.cumulusnetworks.com/setup/cumulus-apps-deb.pubkey | apt-key add -
add-apt-repository "deb [arch=amd64] https://apps3.cumulusnetworks.com/repos/deb $(lsb_release -cs) roh-3"
apt-get update
apt-get install -y frr --assume-yes --force-yes
sysctl net.ipv4.ip_forward=1
ip link set dev eth1 up
ip link add link eth1 name eth1.11 type vlan id 11
ip link add link eth1 name eth1.12 type vlan id 12
ip link set dev eth1.11 up
ip link set dev eth1.12 up
ip link set dev eth2 up
ip add add 192.168.251.1/30 dev eth2
ip add add 192.168.249.1/24 dev eth1.11
ip add add 192.168.250.1/27 dev eth1.12
sed -i "s/\(zebra *= *\). */\1yes/" /etc/frr/daemons
sed -i "s/\(ospfd *= *\). */\1yes/" /etc/frr/daemons
service frr restart

vtysh -c 'conf t'
vtysh -c 'router ospf'
vtysh -c 'redistribute connected'
vtysh -c 'exit'
vtysh -c 'interface eth2'
vtysh -c 'ip ospf area 0.0.0.0'
vtysh -c 'exit'
vtysh -c 'write'

