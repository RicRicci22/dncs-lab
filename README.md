# DNCS-LAB Assignment A.Y. 2018-2019

Project by Riccardo Ricci and Sergio Povoli for Design of Networks and Communication System hosted by UniTN

## Table of contents
* [Requirements](#requirements)
* [Network Map](#network-map)
* [Our approach to project](#our-approach-to-project)  
  * [Subnetting](#subnetting)  
  * [Ip address assignment](#ip-address-assignment)
  * [Virtual Lans](#virtual-lans)
  * [Vagrant File](#vagrant-file)
  * [host1a.sh](#host1ash)
  * [host1b.sh](#host1bsh)
* [How-to test](#how-to-test)
  *[Switch test](#switch)
  *[Rouer-1 test](#router-1)

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
        |  A  |       192.168.250.1/27  |  eth1.12                  | 192.168.252.2/30
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

# Our approach to project

## Subnetting
We decided to split our network in 4 subnetworks, 2 of these are Vlan based.  
The 4 networks are:  
-**A** The area that contains host-1-a and all the similar hosts in this subnet and the router-1 port. This is Vlan based.  
-**B** The area that contains host-1-b and all the similar hosts in this subnet and the router-1 port. This is Vlan based.  
-**C** The area that contains host-2-c and the router-2 port.  
-**D** The area that contains other router-1 port and other router-2 port.

## Ip address assignment
In this assignment our aim was to follow this requirement:  
- Up to 130 hosts in the same subnet of host-1-a  
- Up to 25 hosts in the same subnet of host-1-b  
- Consume as few IP addresses as possible  
For this reason we decided to assign this ip subnets:

| Network |     Network Mask      | Available IPs |
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

Whit this formula we decided all the subnets so that *N* is as close as possible to the requested ip number.

## Virtual Lans
We decided to use vlans for the networks A and B. In fact, networks A and B are, hypothetically, on the same broadcast area. Using vlans we can split this area in two virtual subnets without adding any router. We decide to proceed like this because in the assignment, either the virtual subnet containing host-1-a and the one containing host-1-b must be able to reach a web-server located on host-2-c and retrieve a simple web page. 
We setup the switch interface linked to the router in trunk mode, in order to simultaneously manage the traffic coming from 2 distinct vlans on the same interface.

| Network | VLan ID |
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
The vagrant File initialize all the necessary virtual machine and the link between the virtual machine. Now we will focused on this command line that it is present in all virtual machine initialization.  
`NameOfVM.vm.provision "shell", path: "NameOfFile.sh"`  
Every virtual machine [*NameofVM*] has a specific file [*NameOfFile*] to runs any configured provisioner. Provisioner in Vagrant allow you to automatically install software, alter configurations, and more on the machine as part of the `vagrant up` process. For this reason the *NameOfFile.sh* is a scrip that contain all the specific commands to configure our different VMs.

## host1a.sh

Host1a.sh contains this line:  

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

Now we focus on the most important command in this file:

*Line 4:* We installed `curl`, a very important command for have the possibility to transfer a data of a web-page hosted in `host-2-c` that we will browse.
*Line 6:* We set `eth1`, the host interface, UP.  
*Line 7:* In this line we assigned an IP adress with properly subnet-mask to the `host-1-a eth1`.  
*Line 8:* We assigned a static route for all the packet with 192.168.248.0/21 destination. This destination includes all the other network in this project. All packet with 192.168.248.0/21 destination goes to the 192.168.249.1 the ip address of `eth1.11 router-1` interface.  

## host1b.sh

Host1b.sh contains this line:  

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

Now we focus on the most important command in this file:

*Line 4:* We installed `curl`, a very important command for have the possibility to transfer a data of a web-page hosted in `host-2-c` that we will browse.
*Line 6:* We set `eth1`, the host interface, UP.  
*Line 7:* In this line we assigned an IP address with properly subnet-mask to the `host-1-b eth1`.  
*Line 8:* We assigned a static route for all the packet with 192.168.248.0/21 desination. This destination includes all the other network in this project. All packet with 192.168.248.0/21 destination goes to the 192.168.250.1 the ip address of `eth1.12 router-1` interface.

# How-to test 
 - Install Virtualbox and Vagrant
 - Clone this repository
`git clone https://github.com/SergioPovoli/dncs-lab.git`
 - You should be able to launch the lab from within the cloned repo folder.
```
cd dncs-lab
~/dncs-lab$ vagrant up --provision
```
Once you launch the vagrant script, it may take a while for the entire topology to become available. We choose to include the option --provision because, with our pc's, when we omit this option, all commands in the shell files become invisible to vagrant, so the virtual machines don't work. Don't worry if, while vagrant is setting up virtual machine, appears on the screen some red lines, it will be fine. 
 - Verify the status of the 4 VMs
 ```
 [dncs-lab]$ vagrant status                                                                                                                                                        
Current machine states:

router-1                  running (virtualbox)
router-2                  running (virtualbox)
switch                    running (virtualbox)
host-1-a                  running (virtualbox)
host-1-b                  running (virtualbox)
host-2-c                  running (virtualbox)

```
Hopefully, this command will return  something like that. It means that our six VM's, corresponding to the six components of the topology, are set up and running. You can confirm the fact by opening VirualBox and see that there are six virtual machines running named dncs-lab_router-1, dncs-lab_router-2 etc.
- Once all the VMs are running verify you can log into all of them, by opening six terminals, log into the cloned folder and and type this commands:  
Terminal 1 --> `vagrant ssh router-1`  
Terminal 2 --> `vagrant ssh router-2`  
Terminal 3 --> `vagrant ssh switch`  
Terminal 4 --> `vagrant ssh host-1-a`  
Terminal 5 --> `vagrant ssh host-1-b`  
Terminal 6 --> `vagrant ssh host-2-c`  

This commands allow to log in into the VM's, every login must return the same message (because all VM's are Ubuntu Machines). The message is the following:

***Welcome to Ubuntu 14.04.3 LTS (GNU/Linux 3.16.0-55-generic x86_64)  
Documentation:  https://help.ubuntu.com/  
 Development Environment  
Last login: Wed Nov 21 05:39:35 2018 from 10.0.2.2  
[08:22:11 vagrant@router-1:~] $  ***
 
 In this piece of terminal you can see our last login, in your case, at the very first time you log in, this line will be omitted.
 Ok, here finishes the common part, so, starting from this point, we will divide the rest of this paragraph in six subparts, everyone of them referring to how to use a specific VM (host-1-a router-1 router-2 host-2-c). Apart from how to use host-1-a and host-1-b, that are the hosts from where you are able to retrieve a web-page from host-2-c, we describe commands in switch and in the routers to verify that some functions such as ospf are running properly.
 
  - When logged, get the superuser permission permanently running this command on every VM: 
 ```
 sudo su 
 ```
 This is useful to skip the keyword sudo in the next commands that needs the superuser permission. 
## Host-1-a
 At this point you must be logged into the VM of host-1-a as a superuser with the command shown below. The principal commands of host-1-a are the same of host-1-b so I omit to discuss of either host-1-a and host-1-b and discuss only the first, the same command can run, with the same purposes, on host-1-b. 
 From this host (and from host-1-b) we are able to retrieve a simple web-page from a web-server apache running on host-2-c. We decided to install from shell files the functionality curl, that permit, among other tasks, to make requests on specific ports on a server. Here's how:
 - first of all put this command in the terminal 
  ``` 
   curl 192.168.252.2:8080/index.html 
  ```
This command send an http request for the file index.html on port 8080 of the web-server running on host-2-c, on host-2-c we configure the server to accept requests on this port and assume them as http requests. So the web-server will answer with the file, that will be printed on the terminal. You must copy the code from the line  <!DOCTYPE html> to </html> and paste it in an empty editor file. Save the file with a name and the extension .html, then open it with a browser. After this steps you might be able to see a simple web-page containing our name, our numbers, and a simple title. It's simple because the only purpose of this page web is to prove that the web-server works properly. 

Another command that you might would use is this:
  ``` 
   ifconfig
  ```
  This command displays the list of Ethernet interfaces, and their options such as the ip associated or whatever, present in the host. It will show an eth1 that is the interface linked with the switch with its ip address, eth0 that is the pseudo-interface from whom the virtual machine deal with our net-card and a loop-back interface, that is, in practice, the localhost of the VM. 
  
  The last command we want to talk about in host-1-a is this:
  ``` 
  route -nve
  ```
  This command show on the terminal the routing table of the virtual machine. Reading the table is pretty easy, we have the destination and the netmask (here called genmask) and the gateway. In this case we have add a static route, that send packet destinate to every other subnet to the gateway (the router-1 eth1 interface ip). This is visible in the third line of the table.

## Switch

As below you must be logged into switch VM as a superuser. To manage VLANs we install Open vSwitch on the VM. This tool give us the opportunity to virtually divide the switch in two switches, one for the, here called vlan11 and one for the vlan12. You can find more information about this choice in the above part. Here we describe the most useful command in switch. They aren't configuration commands, but only informational commands, because the configuration commands runs from within shell files.
The first command is this: 
  ``` 
   ovs-vsctl list-br
  ```
  This command show on the terminal a list of all the bridges present in the VM. But what are bridges? In these case we refer to a bridge as a switch, so we can say that it's a list of all the switches present. If this command is run inside this VM, the feedback must be:
 ***switch*** 
  That is in fact the only bridge that we create inside this VM.
  
  Another command, similar to this immediately above is:
    
``` 
   ovs-vsctl list-ports switch
   ```
  
 This command show all the ports related to the switch. The output must be
  ***eth1
  eth2
  eth3***
  Two ports connected to the hosts 1-a and 1-b and a port connected witch router-1.
  
  For a deeply description of ports on the switch you must run this command:
  ``` 
   ovs-vsctl show
   ```
   After the execution of this command, the output must be:
     
***
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
***
    
Ports are displayed with their name, their associated interface and their tag, that means that it is a port associated with a VLAN. Moreover, it is displayed the versione of open vSwitch installed onto the machine.  
  
## Router-1

  Commands shown here, just like in host-1-a, are the same for router-2, so we describe router-1. Commands for router-2 are the same. Even here, like the switch, all the commands that we're about to list are for gather informations about the services running on our router. 
  The first command we wanna talk about is this:
  ``` 
  service frr status
  ```
  The output must be 
  ***zebra is running
  ospfd is running***
