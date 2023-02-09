
######################################################### 1 
# pr-dd-yha01

# disable fw, selinux, nm controller
systemctl disable firewalld
systemctl disable NetworkManager
vi /etc/selinux/config 
reboot

## network 

# bond0 active standby

/etc/sysconfig/network-scripts/ifcfg-ens2f0
TYPE=Ethernet
DEVICE=ens2f0
ONBOOT=yes
BOOTPROTO=none
USERCTL=no
MASTER=bond0
SLAVE=yes

/etc/sysconfig/network-scripts/ifcfg-ens2f1d1
TYPE=Ethernet
DEVICE=ens2f1d1
ONBOOT=yes
BOOTPROTO=none
USERCTL=no
MASTER=bond0
SLAVE=yes


/etc/sysconfig/network-scripts/ifcfg-bond0
DEVICE=bond0
TYPE=Ethernet
BONDING_MASTER=yes
ONBOOT=yes
BOOTPROTO=none
USERCTL=no
NM_CONTROLLED=no
BONDING_OPTS="mode=1 miimon=100"

# IP vlan
# 102	Sys_log	/30	10.51.50.85		10.51.50.86
# 103	OAM	/30	10.51.50.89	x	10.51.50.90

/etc/sysconfig/network-scripts/ifcfg-bond0.102 could be:
VLAN=yes
DEVICE=bond0.102
BOOTPROTO=static
ONBOOT=yes
IPADDR=10.51.50.85
NETMASK=255.255.255.252
GATEWAY=10.51.50.86

/etc/sysconfig/network-scripts/ifcfg-bond0.103 could be:
VLAN=yes
DEVICE=bond0.103
BOOTPROTO=static
ONBOOT=yes
IPADDR=10.51.50.89
NETMASK=255.255.255.252
GATEWAY=10.51.50.90

# Default gw
# https://coderwall.com/p/iqtvhw/default-gateway-on-centos
/etc/sysconfig/network
GATEWAY=bond0.103

#
# ip route add 10.4.20.0/24 via 10.51.50.90 dev bond0.103
/etc/sysconfig/network-scripts/route-bond0.103
10.4.20.0/24 via 10.51.50.90 dev bond0.103

# C30
echo "10.53.106.40/29 via 10.53.146.73 dev bond0.102" >> /etc/sysconfig/network-scripts/route-bond0.102
systemctl restart network

# Q9
echo "10.53.110.128/29  via 10.53.146.9 dev bond0.102" >> /etc/sysconfig/network-scripts/route-bond0.102
systemctl restart network

######################################################### 2 
# pr-dd-gbt01

# disable fw, selinux, nm controller
systemctl disable firewalld
systemctl disable NetworkManager
vi /etc/selinux/config 
reboot

## network 

# bond0 active standby

/etc/sysconfig/network-scripts/ifcfg-ens2f0
TYPE=Ethernet
DEVICE=ens2f0
ONBOOT=yes
BOOTPROTO=none
USERCTL=no
MASTER=bond0
SLAVE=yes

/etc/sysconfig/network-scripts/ifcfg-ens2f1d1
TYPE=Ethernet
DEVICE=ens2f1d1
ONBOOT=yes
BOOTPROTO=none
USERCTL=no
MASTER=bond0
SLAVE=yes


/etc/sysconfig/network-scripts/ifcfg-bond0
DEVICE=bond0
TYPE=Ethernet
BONDING_MASTER=yes
ONBOOT=yes
BOOTPROTO=none
USERCTL=no
NM_CONTROLLED=no
BONDING_OPTS="mode=1 miimon=100"

# IP vlan
# 102	Sys_log	/30	10.51.158.141		10.51.158.142
# 103	OAM	/30	10.51.158.145	x	10.51.158.146


/etc/sysconfig/network-scripts/ifcfg-bond0.102 could be:
VLAN=yes
DEVICE=bond0.102
BOOTPROTO=static
ONBOOT=yes
IPADDR=10.51.158.141
NETMASK=255.255.255.252
GATEWAY=10.51.158.142

/etc/sysconfig/network-scripts/ifcfg-bond0.103 could be:
VLAN=yes
DEVICE=bond0.102
BOOTPROTO=static
ONBOOT=yes
IPADDR=10.51.158.145
NETMASK=255.255.255.252
GATEWAY=10.51.158.146

# Default gw
# https://coderwall.com/p/iqtvhw/default-gateway-on-centos
/etc/sysconfig/network
GATEWAY=bond0.103