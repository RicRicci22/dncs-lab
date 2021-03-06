# DNCS-LAB Assignment A.Y. 2018-2019

On this project works, as collaborators, Riccardo Ricci and Sergio Povoli for the course of "Design of Networks and Communication Systems" hosted in UniTN. 

## Table of contents
* [Assigment](#assigment)
* [Requirements](#requirements)
* [Network Map](#network-map)
* [Our approach to project](#our-approach)  
  * [Subnetting](#subnetting)  
  * [Ip address assignment](#ip-address-assignment)
  * [Virtual Lans](#virtual-lans)
  * [Vagrant File](#vagrant-file)
  * [host1a.sh](#host1ash)
  * [host1b.sh](#host1bsh)
  * [host2c.sh](#host2csh)
  * [switch.sh](#switchsh)
  * [router1.sh](#router1sh)
  * [router2.sh](#router2sh)
* [How-to test](#how-to-test)  
  * [Common Part Test](#common-part)
  * [Host-1-a Test](#host-1-a)
  * [Host-1-b Test](#host-1-b)
  * [Switch Test](#switch)
  * [Rouer-1 test](#router-1)
  * [Rouer-2 test](#router-2)
  * [Host-2-c Test](#host-2-c)
*  [Conclusions](#final-comments)

# Assigment
This is the project Assigment:  
Based the Vagrantfile and the provisioning scripts available at: https://github.com/dustnic/dncs-lab the candidate is required to design a functioning network where any host configured and attached to router-1 (through switch) can browse a website hosted on host-2-c.  
The sub-netting needs to be designed to accommodate the following requirement:  
- Up to 130 hosts in the same subnet of host-1-a  
- Up to 25 hosts in the same subnet of host-1-b  
- Consume as few IP addresses as possible  

# Requirements
 - 10GB disk storage
 - 2GB free RAM
 - Virtualbox
 - Vagrant (https://www.vagrantup.com)
 - Internet

# Network Map


        +----------------------------------------------------------------+
        |                                    192.168.251.1/30            |
        |                                        ^     192.168.251.2/30  |
        |                                        |        ^              |eth0
        +--+--+                   +------------+ |        |  +------------+
        |     |                   |            | |        |  |            |
        |     |               eth0|            |eth2     eth2|            |
        |     +-------------------+  router-1  +-------------+  router-2  |
        |     |                   |            |             |            |
        |     |                   |            |             |            |
        |  M  |                   +------------+             +------------+
        |  A  |                         |eth1                   eth1| 192.168.252.1/30
        |  N  |       192.168.249.1/24  |  eth1.11                  |
        |  A  |       192.168.250.1/27  |  eth1.12              eth1| 192.168.252.2/30
        |  G  |                         |                     +-----+----+
        |  E  |                         |eth1                 |          |
        |  M  |               +-------------------+           |          |
        |  E  |           eth0|    TRUNK PORT     |           | host-2-c |
        |  N  +---------------+      SWITCH       |           |          |
        |  T  |               | 11             12 |           |          |
        |     |               +-------------------+           +----------+
        |  V  |                  |eth2         |eth3                |eth0
        |  A  |                  |             |                    |
        |  G  |                  |             |                    |
        |  R  | 192.168.249.2/24 |eth1     eth1| 192.168.250.2/27   |
        |  A  |           +----------+     +----------+             |
        |  N  |           |          |     |          |             |
        |  T  |       eth0|          |     |          |             |
        |     +-----------+ host-1-a |     | host-1-b |             |
        |     |           |          |     |          |             |
        |     |           |          |     |          |             |
        ++-+--+           +----------+     +----------+             |
        | |                                 |eth0                   |
        | |                                 |                       | 
        | +---------------------------------+                       |
        |                                                           |
        |                                                           |
        +-----------------------------------------------------------+

# Our approach 

## Subnetting
We decided to split our network in 4 subnetworks, 2 of these are Vlan based.  
The 4 networks are:  
-**A**: area that contains host-1-a, other hosts 128 and the router-1 port (eth.11). This is Vlan based.  
-**B**: area that contains host-1-b, other 23 hosts and the router-1 port (eth.12). This is Vlan based.  
-**C**: area that contains host-2-c and the router-2 port (eth1).  
-**D**: area that contains other router-1 port (eth2) and other router-2 port (eth2).

## Ip address assignment
In this project our aim was to follow this requirement:  
- Up to 130 hosts in the same subnet of host-1-a  
- Up to 25 hosts in the same subnet of host-1-b  
- Consume as few IP addresses as possible  
So we decided to assign this ip pools to the various subnets:

| Network |     Ip/Network Mask      | Available IPs |
|:-------:|:---------------------:|:-------------:|
|   **A** |   192.168.249.0/24    | (2^8)-2 = 254 |
|   **B** |   192.168.250.0/27    | (2^5)-2 = 30  |
|   **C** |   192.168.252.0/30    | (2^2)-2 = 2   |
|   **D** |   192.168.251.0/30    | (2^2)-2 = 2   |  

We calculated the available number [*N*] with this formula **((2^M)-2)**.  
Where:
- *N* is the available IPs  
- *M* is the bit dedicated to the host part [e.g. for the Network **A** id 32-24=8]. M belongs to Natural number.
- *-2* is the the unavailable ip in any network. In fact every subnet has 2 dedicate ip, one for broadcast and one for network.  

Whit this formula we decided, for every subnet, how many bit in the ip reserve for the host and how many for the subnet. We chose to assign host ip bits (M) so that *N* is as close as possible to the requested ip numbers.

## Virtual Lans
We decided to use vlans for the networks A and B. Using vlans we can split the switch in two virtual switches. We decide to proceed like this because in the assignment, the virtual subnet containing host-1-a and the one containing host-1-b must be separated in terms of broadcasts area on the switch.
We setup the switch interface linked to the router in trunk mode, in order to simultaneously manage the traffic coming from 2 distinct vlans on the same interface.

| Network | VLan TAG |
|:-------:|:-------:|
| **A**   | 11      |
| **B**   | 12      |  

Now the Interface of the **A** Network is:  

| Interface | Host       | Vlan Tag | IP            |
|:---------:|:----------:|:--------:|:-------------:|
| eth1.11   | `router-1` | 11       | 192.168.249.1 |
| eth1      | `host-1-a` | None     | 192.168.249.2 |  

Now the Interface of the **B** Network is:  

| Interface | Host       | Vlan Tag | IP            |
|:---------:|:----------:|:--------:|:-------------:|
| eth1.12   | `router-1` | 12       | 192.168.250.1 |
| eth1      | `host-1-b` | None     | 192.168.250.2 |

## Vagrant File
The vagrantfile initialize all the necessary virtual machine and the link between them. Now we will focus on this command line that is present in every virtual machine initialization in the Vagrantfile.  
`NameOfVM.vm.provision "shell", path: "NameOfFile.sh"`  
Every virtual machine [*NameofVM*] has a specific file [*NameOfFile*] that runs any configured provisioner. Provision in Vagrant allow you to automatically install software, and configure the machines as part of the `vagrant up` process. For this reason the *NameOfFile.sh* is a scrip that contain all the specific commands to configure our different VMs.

## host1a.sh

Host1a.sh contains this lines:  

```
1 export DEBIAN_FRONTEND=noninteractive  
2 sudo su  
3 apt-get update  
4 apt-get install -y curl --assume-yes  
5 apt-get install -y tcpdump --assume-yes  
6 ip link set dev eth1 up  
7 ip add add 192.168.249.2/24 dev eth1  
8 ip route add 192.168.248.0/21 via 192.168.249.1  

```

Now we focus on the most important commands in this file:

**Line 4:** We installed `curl`, an important command that five the possibility to transfer data of the web-page hosted in `host-2-c` that we will browse.  
**Line 5:** We install `tcpdump`, a simple packet sniffer. A brief explanation is in the paragraph [how to test](#how-to-test).   
**Line 6:** We set `eth1`, the host interface, UP.  
**Line 7:** In this line we assigned an IP address with properly subnet-mask to the `host-1-a eth1`.  
**Line 8:** We assigned a static route for all the packet with 192.168.248.0/21 destination. This destination includes all the other subnets in this project. All packet with 192.168.248.0/21 destination goes to the 192.168.249.1 the ip address of `eth1.11 router-1` interface.  

## host1b.sh

Host1b.sh contains this lines:  

```
1 export DEBIAN_FRONTEND=noninteractive
2 sudo su 
3 apt-get update
4 apt-get install -y curl --assume-yes
5 apt-get install -y tcpdump --assume-yes
6 ip link set dev eth1 up
7 ip add add 192.168.250.2/27 dev eth1
8 ip route add 192.168.248.0/21 via 192.168.250.1 

```

This code performs the same task as the code above in host-1-a, the only differences are the interfaces and the ip that in this case refers to the subnet B. 


## host2c.sh

Host2c.sh contains this lines:  

```
1 export DEBIAN_FRONTEND=noninteractive
2 sudo su 
3 apt-get update
4 apt-get install -y apt-transport-https ca-certificates curl software-properties-common --assume-yes --force-yes
5 curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
6 add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
7 apt-get update
8 apt-get install -y docker-ce --assume-yes --force-yes
9 ip link set dev eth1 up
10 ip add add 192.168.252.2/30 dev eth1
11 ip route add 192.168.248.0/21 via 192.168.252.1
12
13 docker rm $(docker ps -a -q)
14 docker run -dit --name SRwebserver -p 8080:80 -v /home/user/website/:/usr/local/apache2/htdocs/ httpd:2.4
15 
16 echo "<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Pagina web di Sergio e Riccardo</title>
</head>
<body>
    <h1 style='color: #5e9ca0;'>HI, THIS IS A DEMO WEBPAGE&nbsp;</h1>
    <h2 style='color: #2e6c80;'>Something silly:</h2>
        <p>  Something silly </p>
    <h2 style='color: #2e6c80;'>Creators:</h2>
	<p>- Riccardo Ricci -- 181398</p>
	<p>- Sergio Povoli -- 185790</p>
	<p><strong>&nbsp;</strong></p>   
</body>
</html>" > /home/user/website/index.html

```

Now we focus on the most important commands in this file:

**Lines 4-5-6-7-8:** This lines download and install *docker*.  
**Line 9-10-11:** Same as above, but with interfaces and ip's referring to the subnet C.  
**Line 12:** This command kills all docker containers if present, is useful if a user reload the VM more than once (specially if he has done some modify to the project).  
**Line 14:** This command runs a docker container using an apache web-server image [`httpd:2.4`]. With this command line we create our web-server named SRwebserver, that listen for incoming requests on the port 8080.  
**Lines 16 to 29:** With the command echo we insert a simple html code in a file called `index.html`creating the file if not present, overwriting it if it is already present. This file is hosted in the right directory of our SRwebserver.

## switch.sh

Switch.sh contains this lines:  

```
1 export DEBIAN_FRONTEND=noninteractive
2 sudo su 
3 apt-get update
4 apt-get install -y tcpdump --assume-yes
5 apt-get install -y openvswitch-common openvswitch-switch apt-transport-https ca-certificates curl software-properties-common
6 ovs-vsctl --if-exists del-br switch
7 ovs-vsctl add-br switch 
8 ovs-vsctl add-port switch eth1
9 ovs-vsctl add-port switch eth2 tag=11
10 ovs-vsctl add-port switch eth3 tag=12
11 ip link set dev eth1 up
12 ip link set dev eth2 up
13 ip link set dev eth3 up
14 ip link set dev ovs-system up

```

Now we focus on the most important commands in this file:

**Line 5:** This lines download and install *open vSwitch*. Open vSwitch is an open-source implementation of a distributed virtual multilayer switch. The main purpose of Open vSwitch is to provide a switching stack for hardware virtualization environments.  
**Line 6:** This command delete the bridge named 'switch' if present, is useful if a user load the VM more than once maybe after some updates.  
**Line 7:** In this line we add a bridge called 'switch'.  
**Line 8:** In this line we add `eth1` port to the 'switch' bridge.  
**Line 9:** In this line we add `eth2` port to the 'switch' bridge. This port is tagged with tag=11 in fact it belongs to **A**,Vlan based, subnet.  
**Line 10:** In this line we add `eth3` port to the 'switch' bridge. This port is tagged with tag=12 in fact it belongs to **B**,Vlan based, subnet.  
**Lines 11 to 14:** We set `eth1`, `eth2`,`eth3` and `ocs-system`, the switch interfaces and the ovs system, UP.

## Router1.sh

Router1.sh contains this lines:  

```
1 export DEBIAN_FRONTEND=noninteractive
2 sudo su 
3 apt-get update
4 apt-get install -y tcpdump apt-transport-https ca-certificates curl software-properties-common --assume-yes --force-yes
5 wget -O- https://apps3.cumulusnetworks.com/setup/cumulus-apps-deb.pubkey | apt-key add -
6 add-apt-repository "deb [arch=amd64] https://apps3.cumulusnetworks.com/repos/deb $(lsb_release -cs) roh-3"
7 apt-get update
8 apt-get install -y frr --assume-yes --force-yes
9 sysctl net.ipv4.ip_forward=1
10 ip link set dev eth1 up
11 ip link add link eth1 name eth1.11 type vlan id 11
12 ip link add link eth1 name eth1.12 type vlan id 12
13 ip link set dev eth1.11 up
14 ip link set dev eth1.12 up
15 ip link set dev eth2 up
16 ip add add 192.168.251.1/30 dev eth2
17 ip add add 192.168.249.1/24 dev eth1.11
18 ip add add 192.168.250.1/27 dev eth1.12
19 sed -i "s/\(zebra *= *\). */\1yes/" /etc/frr/daemons
20 sed -i "s/\(ospfd *= *\). */\1yes/" /etc/frr/daemons
21 service frr restart
22 vtysh -c 'conf t' -c 'router ospf' -c 'redistribute connected' -c 'exit' -c 'interface eth2' -c 'ip ospf area 0.0.0.0' -c 'exit' -c 'exit' -c 'write'

```

Now we focus on the most important commands in this file:

**Line 8:** In this line we install FRR. FRRouting is an IP routing protocol suite for Linux and Unix platforms which includes protocol daemons for BGP, IS-IS, LDP, OSPF, PIM, and RIP. In fact we choose to make a dynamic routing between two router. We choose to use OSPF.  
**Line 9:** This line set up the forwarding in the router. It must to be set to 1 if you want the router works properly.  
**Lines 10-13-14-15:** We set `eth1`,  `eth1.11`,  `eth1.12`,  `eth2`, the router interface, UP.  
**Line 11-12:** In this line we add add links `eth1.11` and `eth1.12`. This 2 links are Vlan type and respectively has id 11 and 12.  
**Lines 16-17-18** In this lines we assign IP addresses with properly subnet-masks to `router-1 eth1`, `router-1 eth1.11`, `router-1 eth1.12`.  
**Lines 19-20:** In this line we automatically modify the /etc/frr/frr.daemon without open the vim editor. We active the Zebra daemon and the Ospfd daemon. In this manner the router-1 works with OSPF protocol.  
**Line 21:** We restart frr to update the new configuration.  
**Line 22:** With this lines we automatically modify the /etc/frr//frr.conf. It is a sequence of vtysh command that configure router to work correctly with a proper ospf area and other ospf option. In fact, vtysh provides an environment where the users are able to manage daemons.

## Router2.sh

Router2.sh contains this line:  

```
1 export DEBIAN_FRONTEND=noninteractive
2 sudo su 
3 apt-get update
4 apt-get install -y tcpdump apt-transport-https ca-certificates curl software-properties-common --assume-yes --force-yes
5 wget -O- https://apps3.cumulusnetworks.com/setup/cumulus-apps-deb.pubkey | apt-key add -
6 add-apt-repository "deb [arch=amd64] https://apps3.cumulusnetworks.com/repos/deb $(lsb_release -cs) roh-3"
7 apt-get update
8 apt-get install -y frr --assume-yes --force-yes
9 sysctl net.ipv4.ip_forward=1
10 ip link set dev eth1 up
11 ip link set dev eth2 up
12 ip add add 192.168.251.2/30 dev eth2
13 ip add add 192.168.252.1/30 dev eth1
14 sed -i "s/\(zebra *= *\). */\1yes/" /etc/frr/daemons
15 sed -i "s/\(ospfd *= *\). */\1yes/" /etc/frr/daemons
16 service frr restart
17 vtysh -c 'conf t' -c 'router ospf' -c , while supporting multiple protocols and standards.1 and id 12'redistribute connected' -c 'exit' -c 'interface eth2' -c 'ip ospf area 0.0.0.0' -c 'exit' -c 'exit' -c 'write'

```

Now we focus on the most important commands in this file:

**Lines 10-11:** We set `eth1`,  `eth2`, the router interface, UP.  
**Lines 12-13** In this lines we assign IP addresses with properly subnet-masks to the `router-2 eth1`, `router-2 eth2`.  Here we don't have VLAN based interfaces. 

# How-to test 

 - Install Virtualbox and Vagrant
 - Clone this repository
`git clone https://github.com/SergioPovoli/dncs-lab.git`
 - You should be able to launch the lab from within the cloned repo folder.
```
cd dncs-lab
~/dncs-lab$ vagrant up --provision
```
Once you launch the vagrant script, it may take a while for the entire topology to become available. We choose to include the option --provision because, with our pc's, when we omit this option, all commands in the shell files become invisible to vagrant, so the virtual machines start but without configuration. Don't worry if, while vagrant is working, appears on the screen some red lines, it will be fine. 
 - Verify the status of the 4 VMs
 ```
 vagrant status 
```
- Hopefully, this command will return  something like that:
```
Current machine states:

router-1                  running (virtualbox)
router-2                  running (virtualbox)
switch                    running (virtualbox)
host-1-a                  running (virtualbox)
host-1-b                  running (virtualbox)
host-2-c                  running (virtualbox)

```
It means that our six VM's, corresponding to the six components of the topology, are set up and running. You can confirm the fact by opening VirualBox and see that there are six virtual machines running named dncs-lab_router-1, dncs-lab_router-2 etc.  
## Common part
This part reports commands you can use in every VM with the same purposes.  
- Once all the VMs are running verify you can log into all of them, by opening six terminals, log into the cloned repo folder and and type this commands:  
Terminal 1 --> `vagrant ssh router-1`  
Terminal 2 --> `vagrant ssh router-2`  
Terminal 3 --> `vagrant ssh switch`  
Terminal 4 --> `vagrant ssh host-1-a`  
Terminal 5 --> `vagrant ssh host-1-b`  
Terminal 6 --> `vagrant ssh host-2-c`  

This commands allow to log in into the VM's, every login must return the same message (because all VM's are Ubuntu Machines). The message is the following:

```
Welcome to Ubuntu 14.04.3 LTS (GNU/Linux 3.16.0-55-generic x86_64)  
Documentation:  https://help.ubuntu.com/  
  * Development Environment  
Last login: Wed Nov 21 05:39:35 2018 from 10.0.2.2
[08:22:11 vagrant@router-1:~] $
```
 
In this piece of terminal you can see our last login, in your case, at the very first time you log into the VMs, this line will be omitted.  
 - When logged, get the superuser permission permanently running this command on every VM:  
 ```
sudo su 
 ```  
This is useful to skip the keyword sudo in the next commands that needs the superuser permission.  
- Another command that you might would use on every VM is the following:  
  ``` 
   ifconfig
  ```  
It displays the list of Ethernet interfaces present in the host and their options such as the ip associated or whatever. In every subpart we report the output of code that occurs on our VMs.  
- Having the list of Ethernet interfaces you can use this command on one of these
 ``` 
   tcpdump -i interfaceName
  ```  
  This command allow to sniff the packets on an Ethernet Interface, such as program like WireShark do. It is useful if you want to trace the route of a packet from the source to destination, and even to debug errors in routes. After the execution of this command, every information of packets passing trought the interface will be displayed, such as the protocol at level four the packet belongs and other informations. 
- Another command we want to discuss in the common section is this:  
  ``` 
  route -nve
  ```  
This command show on the terminal the routing table of the virtual machine. Reading the table is pretty easy, we have the destination and the net-mask (here called genmask) and the gateway. In every subpart we report the output of code that occurs on our VMs.  

Ok, here finishes the common section so, starting from this point, we will divide the rest of this paragraph in six subparts, everyone of them referring to how to use a specific VM (host-1-a router-1 router-2 host-2-c). Apart commands that allows you, from host-1-a and host-1-b, to retrieve a web-page from host-2-c, we describe commands in the switch and routers to verify that some functions such as ospf are running properly.  
## Host-1-a  
At this point you must be logged into the VM of host-1-a as a superuser with the command shown below. The principal commands of host-1-a are the same of host-1-b so I omit to discuss of either host-1-a and host-1-b and discuss only the first, the same commands can run, with the same purposes, on host-1-b.  
From this host (and from host-1-b) we are able to retrieve a simple web-page from a web-server apache running on host-2-c. We decided to install from shell files the functionality **curl**, that permit, among other tasks, to make requests on specific ports. Here's how:  
 - If you want get the web-page you have to put this command in the terminal:
 ``` 
   curl 192.168.252.2:8080/index.html 
  ```  
This command send a request for the file index.html on port 8080 of the web-server running on host-2-c. On host-2-c, the server is configured to accept requests on this port, assuming them as http requests. So the web-server will answer with the file, that will be printed on the terminal.  You must copy the code from line **!DOCTYPE html** to **/html** and paste it in an empty editor file. Save the file with the extension **.html**, then open it with a browser. After this steps you might be able to see a simple web-page containing our name, our numbers, and a title. It's simple because the only purpose of this page web is to prove that the web-server works properly.  
- Here i report the output of **ifconfig** of host-1-a  
``` 
eth0      Link encap:Ethernet  HWaddr 08:00:27:20:c5:44  
          inet addr:10.0.2.15  Bcast:10.0.2.255  Mask:255.255.255.0
          inet6 addr: fe80::a00:27ff:fe20:c544/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:7625 errors:0 dropped:0 overruns:0 frame:0
          TX packets:2001 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:8278493 (8.2 MB)  TX bytes:182913 (182.9 KB)

eth1      Link encap:Ethernet  HWaddr 08:00:27:3b:1e:80  
          inet addr:192.168.249.2  Bcast:0.0.0.0  Mask:255.255.255.0
          inet6 addr: fe80::a00:27ff:fe3b:1e80/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:6 errors:0 dropped:0 overruns:0 frame:0
          TX packets:16 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:985 (985.0 B)  TX bytes:1264 (1.2 KB)

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
```  
eth0 is the dummy interface that "link" our VM with the Ethernet card of our PC.   eth1 is the interface that link the host with the switch. We can see the ip associated with this interface as well as the subnet-mask. Lo is a fictitious interface, that is, briefly, the local-host.  
- Here i report the output of **route -nve** on host-1-a  
 ```  
Kernel IP routing table
Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface
0.0.0.0         10.0.2.2        0.0.0.0         UG        0 0          0 eth0
10.0.2.0        0.0.0.0         255.255.255.0   U         0 0          0 eth0
192.168.248.0   192.168.249.1   255.255.248.0   UG        0 0          0 eth1
192.168.249.0   0.0.0.0         255.255.255.0   U         0 0          0 eth1
 ```  
In this case we set up a static route, visible in the third line of the table, that permit the delivery of packets destinate to other subnets. Fourth line refers to the subnet ip and mask.  
## Host-1-b
- Output of **ifconfig** performed on host-1-a  
``` 
eth0      Link encap:Ethernet  HWaddr 08:00:27:20:c5:44  
          inet addr:10.0.2.15  Bcast:10.0.2.255  Mask:255.255.255.0
          inet6 addr: fe80::a00:27ff:fe20:c544/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:8456 errors:0 dropped:0 overruns:0 frame:0
          TX packets:2113 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:9395485 (9.3 MB)  TX bytes:201745 (201.7 KB)

eth1      Link encap:Ethernet  HWaddr 08:00:27:10:34:de  
          inet addr:192.168.250.2  Bcast:0.0.0.0  Mask:255.255.255.224
          inet6 addr: fe80::a00:27ff:fe10:34de/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:0 (0.0 B)  TX bytes:648 (648.0 B)

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
 ``` 
- Output of **route -nve** executed on host-1-a
``` 
Kernel IP routing table
Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface
0.0.0.0         10.0.2.2        0.0.0.0         UG        0 0          0 eth0
10.0.2.0        0.0.0.0         255.255.255.0   U         0 0          0 eth0
192.168.248.0   192.168.250.1   255.255.248.0   UG        0 0          0 eth1
192.168.250.0   0.0.0.0         255.255.255.224 U         0 0          0 eth1
``` 
## Switch

As below you must be logged into switch VM as a superuser. To manage VLANs we installed Open vSwitch. This tool give us the opportunity to virtually divide the switch in two switches, one for the, here called vlan11 and one for the vlan12. You can find more information about this choice in the paragraph above. The purpose  of this subparagraph is to describe the most useful command in switch. They aren't configuration commands, but only informational commands, because the configuration commands runs from within shell files.
The first command is this: 
  ``` 
   ovs-vsctl list-br
  ```
  This command show on the terminal a list of all the bridges present in the VM. But what are bridges? In these case we refer to a bridge as a switch, so we can say that it's a list of all the switches present. If this command is run inside this VM, the feedback must be:  
   ```switch``` 
  That is in fact the only bridge that we create inside this VM.  
  Another command, similar to this immediately above is:  
  ``` 
   ovs-vsctl list-ports switch
   ```  
This command show all the Ethernet interfaces related to the bridge chosen. In our case the only bridge is our "switch". The output must be  
  ```
  eth1
  eth2
  eth3
  ```  
  Two interfaces connected to the hosts 1-a and 1-b and one to router-1.  
  
  For a deeper description of ports (eth interfaces) on the switch you must run this command:
  ``` 
   ovs-vsctl show
   ```
   After the execution of this command, the output must be:
   ```     
Bridge switch 
    Port "eth1"  
        Interface "eth1"  
    Port switch  
        Interface switch  
        type: internal  
    Port "eth2"  
        tag: 11  
        Interface "eth2"  
    Port "eth3"  
        tag: 12  
        Interface "eth3"  
 ovs_version: "2.0.2"
```
This command sensitize the previews 2 commands. Ports are displayed with their name, their associated interface and their tag, that means that it is a port associated to a VLAN. Moreover, it is displayed the version of open vSwitch installed onto the machine.  
- Output of the command **ifconfig** on switch:  
```
- eth0    Link encap:Ethernet  HWaddr 08:00:27:20:c5:44  
          inet addr:10.0.2.15  Bcast:10.0.2.255  Mask:255.255.255.0
          inet6 addr: fe80::a00:27ff:fe20:c544/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:12259 errors:0 dropped:0 overruns:0 frame:0
          TX packets:2879 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:13913994 (13.9 MB)  TX bytes:263448 (263.4 KB)

eth1      Link encap:Ethernet  HWaddr 08:00:27:2a:4e:77  
          inet6 addr: fe80::a00:27ff:fe2a:4e77/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:31 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:0 (0.0 B)  TX bytes:2502 (2.5 KB)

eth2      Link encap:Ethernet  HWaddr 08:00:27:c1:cf:b3  
          inet6 addr: fe80::a00:27ff:fec1:cfb3/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:8 errors:0 dropped:0 overruns:0 frame:0
          TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:648 (648.0 B)  TX bytes:648 (648.0 B)

eth3      Link encap:Ethernet  HWaddr 08:00:27:76:ce:8f  
          inet6 addr: fe80::a00:27ff:fe76:ce8f/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:8 errors:0 dropped:0 overruns:0 frame:0
          TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:648 (648.0 B)  TX bytes:648 (648.0 B)

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

ovs-system Link encap:Ethernet  HWaddr 7e:78:89:5c:3f:f8  
          inet6 addr: fe80::7c78:89ff:fe5c:3ff8/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:0 (0.0 B)  TX bytes:648 (648.0 B)

switch    Link encap:Ethernet  HWaddr 08:00:27:2a:4e:77  
          inet6 addr: fe80::6002:c3ff:fef5:3073/64 Scope:Link
          UP BROADCAST RUNNING  MTU:1500  Metric:1
          RX packets:16 errors:0 dropped:0 overruns:0 frame:0
          TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:1296 (1.2 KB)  TX bytes:648 (648.0 B)
```

## Router-1

Commands shown here, just like in host-1-a, are the same for router-2, so we describe router-1. Commands for router-2 are the same. Even here, like the switch, all the commands that we're about to list are for gather informations about the services running on our router. 
The first command we want to talk about is:  
  ```  
  service frr status
  ```  
   The output must be   
  ```  
  * zebra is running
  * ospfd is running
  ```  
  This means that on our router, are running 2 daemons. We don't know much about this two daemons, but together, they permit the **ospf** routing protocol. Zebra delivers informations between routers involved in the protocol, to permit all the routers to gather the informations of the net topology and permit the redaction of the route table, performed we tough by the ospfd daemon (but we are not sure). 
  - Output of the command **route -nve** on router-1:  
 ```
 Kernel IP routing table
Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface
0.0.0.0         10.0.2.2        0.0.0.0         UG        0 0          0 eth0
10.0.2.0        0.0.0.0         255.255.255.0   U         0 0          0 eth0
192.168.249.0   0.0.0.0         255.255.255.0   U         0 0          0 eth1.11
192.168.250.0   0.0.0.0         255.255.255.224 U         0 0          0 eth1.12
192.168.251.0   0.0.0.0         255.255.255.252 U         0 0          0 eth2
192.168.252.0   192.168.251.2   255.255.255.252 UG        0 0          0 eth2
```  
This table is a lot informative! This table is automatically compiled by the ospf protocol. We can see that to the subnets directly connected the protocol assigned the default gateway. We think that this means to the router that they are directly connected and so the packets can be delivered without other gateways in between. The only subnet not connected (the subnet of host-2-c) has a route in the table, that points to the interface eth2, and has an ip gateway that is the ip of the eth2 interface on router-2! That's all. 
  - Output of the command **ifconfig** on router-1:  
 ```
 eth0      Link encap:Ethernet  HWaddr 08:00:27:20:c5:44  
          inet addr:10.0.2.15  Bcast:10.0.2.255  Mask:255.255.255.0
          inet6 addr: fe80::a00:27ff:fe20:c544/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:20191 errors:0 dropped:0 overruns:0 frame:0
          TX packets:4944 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:22791778 (22.7 MB)  TX bytes:433035 (433.0 KB)

eth1      Link encap:Ethernet  HWaddr 08:00:27:a3:f5:33  
          inet6 addr: fe80::a00:27ff:fea3:f533/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:24 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:0 (0.0 B)  TX bytes:1944 (1.9 KB)

eth2      Link encap:Ethernet  HWaddr 08:00:27:41:ec:af  
          inet addr:192.168.251.1  Bcast:0.0.0.0  Mask:255.255.255.252
          inet6 addr: fe80::a00:27ff:fe41:ecaf/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:233 errors:0 dropped:0 overruns:0 frame:0
          TX packets:264 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:19690 (19.6 KB)  TX bytes:22176 (22.1 KB)

eth1.11   Link encap:Ethernet  HWaddr 08:00:27:a3:f5:33  
          inet addr:192.168.249.1  Bcast:0.0.0.0  Mask:255.255.255.0
          inet6 addr: fe80::a00:27ff:fea3:f533/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:0 (0.0 B)  TX bytes:648 (648.0 B)

eth1.12   Link encap:Ethernet  HWaddr 08:00:27:a3:f5:33  
          inet addr:192.168.250.1  Bcast:0.0.0.0  Mask:255.255.255.224
          inet6 addr: fe80::a00:27ff:fea3:f533/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:0 (0.0 B)  TX bytes:648 (648.0 B)

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
```

## Router-2

- Output of the command **route -nve** on router-2:
```
Kernel IP routing table
Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface
0.0.0.0         10.0.2.2        0.0.0.0         UG        0 0          0 eth0
10.0.2.0        0.0.0.0         255.255.255.0   U         0 0          0 eth0
192.168.248.0   192.168.251.2   255.255.248.0   UG        0 0          0 eth2
192.168.249.0   192.168.251.1   255.255.255.0   UG        0 0          0 eth2
192.168.250.0   192.168.251.1   255.255.255.224 UG        0 0          0 eth2
192.168.251.0   0.0.0.0         255.255.255.252 U         0 0          0 eth2
192.168.252.0   0.0.0.0         255.255.255.252 U         0 0          0 eth1

```
- Output of the command **ifconfig** on router-2:  
```
eth0      Link encap:Ethernet  HWaddr 08:00:27:20:c5:44  
          inet addr:10.0.2.15  Bcast:10.0.2.255 Mask:255.255.255.0
          inet6 addr: fe80::a00:27ff:fe20:c544/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:19641 errors:0 dropped:0 overruns:0 frame:0
          TX packets:4206 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:22758492 (22.7 MB)  TX bytes:384497 (384.4 KB)

eth1      Link encap:Ethernet  HWaddr 08:00:27:dc:ee:57  
          inet addr:192.168.252.1  Bcast:0.0.0.0  Mask:255.255.255.252
          inet6 addr: fe80::a00:27ff:fedc:ee57/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:0 (0.0 B)  TX bytes:648 (648.0 B)

eth2      Link encap:Ethernet  HWaddr 08:00:27:56:af:94  
          inet addr:192.168.251.2  Bcast:0.0.0.0  Mask:255.255.255.252
          inet6 addr: fe80::a00:27ff:fe56:af94/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:247 errors:0 dropped:0 overruns:0 frame:0
          TX packets:258 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:20950 (20.9 KB)  TX bytes:21644 (21.6 KB)

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

```
## Host-2-c
This is the host where our webserver is deployed. We installed docker on it, that is a manager of the so called "containers". Containers are an abstraction at the app layer instead of VM that are an abstraction of the hardware. Multiple containers can run on the same machine and share the OS kernel with other containers. Containers take up less space than VMs. To build up a container you need a repository for the "images", that are used by docker to set up our container. We downloaded the image httpd:2.4 that is an image used to set up a container of an apache server. So on this host we have an apache server running in a docker container (the container use less than 3 Mbyte of memory).  
- The first useful command is:  
```
docker image ls 
 ```
 This command list all the docker images present in our docker environment. It will prompt this line
 ```
 REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
httpd               2.4                 2a51bb06dc8b        6 days ago          132MB
 ```
 As mentioned early this is the image that allow docker to create a container that runs an apache server.
 - Another command:
 ```
docker container ls
```
This command display the list of containers running on the docker environment, in our case it prompts this below
 ```
 CONTAINER ID        IMAGE               COMMAND              CREATED             STATUS              PORTS                  NAMES
273d5a3a895c        httpd:2.4           "httpd-foreground"   3 hours ago         Up 3 hours          0.0.0.0:8080->80/tcp   SRwebserver
```
We can see that the server is listening for requests on the port 8080, considering them as http requests (that we know use tcp protocol for a reliable connection). 
- A command to see the docker statistics:
```
docker stats
```
This command gives you some information about the percentage of cpu and memory used by every container, as well as the data in input and output. In our case it displays
```
CONTAINER ID        NAME                CPU %               MEM USAGE / LIMIT     MEM %               NET I/O             BLOCK I/O           PIDS
273d5a3a895c        SRwebserver         0.02%               2.387MiB / 237.7MiB   1.00%               1.3kB / 0B          6.86MB / 0B         0
```
After a curl from the host-1-a we retrieve this
```
CONTAINER ID        NAME                CPU %               MEM USAGE / LIMIT     MEM %               NET I/O             BLOCK I/O           PIDS
273d5a3a895c        SRwebserver         0.02%               2.945MiB / 237.7MiB   1.24%               1.83kB / 907B       7.06MB / 0B         0

```
We see that data in output change from 0 to 907 bytes. In fact the server pushed in output the file requested, so this ratio increases.
- Output of the command **route -nve** on host-2-c:  
```
Kernel IP routing table
Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface
0.0.0.0         10.0.2.2        0.0.0.0         UG        0 0          0 eth0
10.0.2.0        0.0.0.0         255.255.255.0   U         0 0          0 eth0
172.17.0.0      0.0.0.0         255.255.0.0     U         0 0          0 docker0
192.168.248.0   192.168.252.1   255.255.248.0   UG        0 0          0 eth1
192.168.252.0   0.0.0.0         255.255.255.252 U         0 0          0 eth1

```
- Output of the command **ifconfig** on host-2-c:  
```
docker0   Link encap:Ethernet  HWaddr 02:42:30:7c:82:ba  
          inet addr:172.17.0.1  Bcast:172.17.255.255  Mask:255.255.0.0
          inet6 addr: fe80::42:30ff:fe7c:82ba/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:5 errors:0 dropped:0 overruns:0 frame:0
          TX packets:15 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:837 (837.0 B)  TX bytes:1186 (1.1 KB)

eth0      Link encap:Ethernet  HWaddr 08:00:27:20:c5:44  
          inet addr:10.0.2.15  Bcast:10.0.2.255  Mask:255.255.255.0
          inet6 addr: fe80::a00:27ff:fe20:c544/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:96927 errors:0 dropped:0 overruns:0 frame:0
          TX packets:21308 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:113698016 (113.6 MB)  TX bytes:1483861 (1.4 MB)

eth1      Link encap:Ethernet  HWaddr 08:00:27:02:d1:51  
          inet addr:192.168.252.2  Bcast:0.0.0.0  Mask:255.255.255.252
          inet6 addr: fe80::a00:27ff:fe02:d151/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:8 errors:0 dropped:0 overruns:0 frame:0
          TX packets:14 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:616 (616.0 B)  TX bytes:1633 (1.6 KB)

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

veth323e421 Link encap:Ethernet  HWaddr aa:c8:8f:f3:bd:22  
          inet6 addr: fe80::a8c8:8fff:fef3:bd22/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:5 errors:0 dropped:0 overruns:0 frame:0
          TX packets:23 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:907 (907.0 B)  TX bytes:1834 (1.8 KB)
 
```
## Final comments
Here finish our project for the course of Design of Networks and Communication System, must say that we forked the repository from [dustnic/dncs-lab]. This project is powered by dustnic, that we want to thank because he permit us to fork his files and expand it as a project. 
