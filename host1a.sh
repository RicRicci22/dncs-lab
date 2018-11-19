export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y tcpdump --assume-yes
ip link set dev eth1 up
ip add add 192.168.249.2/24 dev eth1