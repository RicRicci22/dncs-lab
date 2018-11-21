# DNCS-LAB Assignment A.Y. 2018-2019

Project by Riccardo Ricci and Sergio Povoli for Design of Networks and Communication System @UniTN

## Table of contents
* [Requirements](#requirements)
* [Network Map](#network-map)
* [Our approach to project](#our_approach_to_project)  
  * [Subnetting](#subnetting)  
  * [Ip address assignment](#ip_address_assignment)


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
        |  E  |           eth0|      TRUNK        |           | host-2-c |
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

| Network |     Network Mask      | available IPs |
|:-------:|:---------------------:|:-------------:|
|   **A** |   192.168.249.0/24    | (2^8)-2 = 254 |
|   **B** |   192.168.250.0/27    | (2^5)-2 = 30  |
|   **C** |   192.168.252.0/30    | (2^2)-2 = 2   |
|   **D** |   192.168.251.0/40    | (2^2)-2 = 2   | 

# How-to
 - Install Virtualbox and Vagrant
 - Clone this repository
`git clone https://github.com/dustnic/dncs-lab`
 - You should be able to launch the lab from within the cloned repo folder.
```
cd dncs-lab
[~/dncs-lab] vagrant up
```
Once you launch the vagrant script, it may take a while for the entire topology to become available.
 - Verify the status of the 4 VMs
 ```
 [dncs-lab]$ vagrant status                                                                                                                                                                
Current machine states:

router                    running (virtualbox)
switch                    running (virtualbox)
host-a                    running (virtualbox)
host-b                    running (virtualbox)
```
- Once all the VMs are running verify you can log into all of them:
`vagrant ssh router`
`vagrant ssh switch`
`vagrant ssh host-a`
`vagrant ssh host-b`
