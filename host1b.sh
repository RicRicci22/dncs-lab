export DEBIAN_FRONTEND=noninteractive
sudo su 
apt-get update
apt-get install -y curl --assume-yes
apt-get install -y tcpdump --assume-yes
ip link set dev eth1 up
ip add add 192.168.250.2/27 dev eth1
ip route add 192.168.248.0/21 via 192.168.250.1