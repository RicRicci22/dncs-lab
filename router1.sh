export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y tcpdump apt-transport-https ca-certificates curl software-properties-common --assume-yes --force-yes
wget -O- https://apps3.cumulusnetworks.com/setup/cumulus-apps-deb.pubkey | apt-key add -
add-apt-repository "deb [arch=amd64] https://apps3.cumulusnetworks.com/repos/deb $(lsb_release -cs) roh-3"
apt-get update
apt-get install -y frr --assume-yes --force-yes
ip link set dev eth1 up
ip link add link eth1 name eth1.11 type vlan id 11
ip link add link eth1 name eth1.12 type vlan id 12
ip link set dev eth1.11 up
ip link set dev eth1.12 up
sysctl net.ipv4.ip_forward=1
ip add add 192.168.251.1/30 dev eth2