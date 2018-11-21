export DEBIAN_FRONTEND=noninteractive
sudo su 
apt-get update
apt-get install -y tcpdump --assume-yes
apt-get install -y openvswitch-common openvswitch-switch apt-transport-https ca-certificates curl software-properties-common
ovs-vsctl add-br switch 
ovs-vsctl add-port switch eth1
ovs-vsctl add-port switch eth2 tag=11
ovs-vsctl add-port switch eth3 tag=12
ip link set dev eth1 up
ip link set dev eth2 up
ip link set dev eth3 up
ip link set dev ovs-system up