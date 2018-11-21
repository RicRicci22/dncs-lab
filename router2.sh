export DEBIAN_FRONTEND=noninteractive
sudo su 
apt-get update
apt-get install -y tcpdump apt-transport-https ca-certificates curl software-properties-common --assume-yes --force-yes
wget -O- https://apps3.cumulusnetworks.com/setup/cumulus-apps-deb.pubkey | apt-key add -
add-apt-repository "deb [arch=amd64] https://apps3.cumulusnetworks.com/repos/deb $(lsb_release -cs) roh-3"
apt-get update
apt-get install -y frr --assume-yes --force-yes
sysctl net.ipv4.ip_forward=1
ip link set dev eth1 up
ip link set dev eth2 up
ip add add 192.168.251.2/30 dev eth2
ip add add 192.168.252.1/30 dev eth1
ip route add 192.168.248.0/21 via 192.168.251.2
sed -i "s/\(zebra *= *\). */\1yes/" /etc/frr/daemons
sed -i "s/\(ospfd *= *\). */\1yes/" /etc/frr/daemons
service frr restart
vtysh -c 'conf t' -c 'router ospf' -c 'redistribute connected' -c 'exit' -c 'interface eth2' -c 'ip ospf area 0.0.0.0' -c 'exit' -c 'exit' -c 'write'
