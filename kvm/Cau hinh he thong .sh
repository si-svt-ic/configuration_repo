----------------------script ------------------------------------
----disable filewall + selinux + root pass ----------------------
passwd root
passwd admin

systemctl disable firewalld

vi /etc/selinux/config

SELINUX=disabled

reboot

---------------hosts name ------------------------
vi /etc/hosts
### Local ipaddress ###
10.38.22.11	node1 node1.local 
10.38.22.12	node2 node2.local		
10.38.22.13	node3 node3.local		
10.38.22.14	node4 node4.local		
10.38.22.15	node5 node5.local		
10.38.22.16	node6 node6.local		
10.38.22.17	node7 node7.local		
10.38.22.18	node8 node8.local		
10.38.22.19	node9 node9.local		
10.38.22.20	node10 node10.local		
10.38.22.21	node11 node11.local		
10.38.22.22	node12 node12.local		
10.38.22.23	node13 node13.local	

### Management ipaddress ###
10.38.16.155		node1.mgt
10.38.16.156		node2.mgt
10.38.16.157		node3.mgt
10.38.16.158		node4.mgt
10.38.16.159		node5.mgt
10.38.16.160		node6.mgt
10.38.16.161		node.7.mgt
10.38.16.162		node8.mgt
10.38.16.163		node9.mgt
10.38.16.164		node10.mgt
10.38.16.165		node11.mgt
10.38.16.166		node12.mgt
10.38.16.167		node13.mgt
10.38.16.168		Camera-AI-1
10.38.16.169		Camera-AI-2
10.38.16.170		storage1-node1.mgt
10.38.16.171		storage1-node2.mgt
10.38.16.172		sansw1.mgt
10.38.16.173		sansw2.mgt
10.38.16.174		tor1.mgt
10.38.16.175		tor2.mgt
10.38.16.176		lb1.mgt
10.38.16.177		lb2.mgt
10.38.16.178		Oneview
10.38.16.179		Reserv

### Storage ipaddress ###
192.168.100.1		node1.storage
192.168.100.2		node2.storage
192.168.100.3		node3.storage
192.168.100.4		node4.storage
192.168.100.5		node5.storage
192.168.100.6		node6.storage
192.168.100.7		node7.storage
192.168.100.8		node8.storage
192.168.100.9		node9.storage
192.168.100.10		node10.storage
192.168.100.11		node11.storage
192.168.100.12		node12.storage
192.168.100.13		node13.storage
192.168.100.14		storage1-ctl1
192.168.100.15		storage1-ctl2

---------------- LACP + IP --------------------------------------
modprobe bonding
ls | grep -i bonding

-----------------------------------------------------

vi /etc/sysconfig/network-scripts/ifcfg-eno1
 
DEVICE=eno1
ONBOOT=yes
BOOTPROTO=none
USERCTL=no
MASTER=bond0
SLAVE=yes

vi /etc/sysconfig/network-scripts/ifcfg-eno2
 
DEVICE=eno2
ONBOOT=yes
BOOTPROTO=none
USERCTL=no
MASTER=bond0
SLAVE=yes

vi /etc/sysconfig/network-scripts/ifcfg-bond0
DEVICE=bond0
TYPE=Ethernet
ONBOOT=yes
BOOTPROTO=none
USERCTL=no
NM_CONTROLLER=no
IPADDR=10.38.22.18
PREFIX=25
GATEWAY=10.38.22.1

BONDING_OPTS="mode=802.3ad miimon=100 lacp_rate=fast"
 
-----------------------------------------------------
vi /etc/sysconfig/network-scripts/ifcfg-eno49
 
DEVICE=eno49
ONBOOT=yes
BOOTPROTO=none
USERCTL=no
MASTER=bond1
SLAVE=yes

vi /etc/sysconfig/network-scripts/ifcfg-eno50
 
DEVICE=eno50
ONBOOT=yes
BOOTPROTO=none
USERCTL=no
MASTER=bond1
SLAVE=yes

vi /etc/sysconfig/network-scripts/ifcfg-bond1
 
DEVICE=bond1
TYPE=Ethernet
ONBOOT=yes
BOOTPROTO=none
USERCTL=no
NM_CONTROLLER=no

BONDING_OPTS="mode=802.3ad miimon=100 lacp_rate=fast"

--------------------------------------------------------------
vi /etc/sysconfig/network-scripts/ifcfg-ens1f0
 
DEVICE=ens1f0
ONBOOT=yes
BOOTPROTO=none
USERCTL=no
MASTER=bond2
SLAVE=yes

vi /etc/sysconfig/network-scripts/ifcfg-ens1f1
 
DEVICE=ens1f1
ONBOOT=yes
BOOTPROTO=none
USERCTL=no
MASTER=bond2
SLAVE=yes

vi /etc/sysconfig/network-scripts/ifcfg-bond2
 
DEVICE=bond2
TYPE=Ethernet
ONBOOT=yes
BOOTPROTO=none
USERCTL=no
NM_CONTROLLER=no
IPADDR=192.168.100.3
PREFIX=24
#GATEWAY=192.168.100.254

BONDING_OPTS="mode=802.3ad miimon=100 lacp_rate=fast"

----------------------------------------------------------------
vi /etc/sysconfig/network-scripts/ifcfg-bond1.423
DEVICE=bond1.423
NAME=bond1.423
VLAN=yes
ONBOOT=yes
BOOTPROTO=none
BRIDGE=br-vlan423
NM_CONTROLLED=no
--------------------
vi /etc/sysconfig/network-scripts/ifcfg-bond1.424

DEVICE=bond1.424
NAME=bond1.424
VLAN=yes
ONBOOT=yes
BOOTPROTO=none
BRIDGE=br-vlan424
NM_CONTROLLED=no
-------------------
vi /etc/sysconfig/network-scripts/ifcfg-br-vlan423
DEVICE=br-vlan423
TYPE=Bridge
BOOTPROTO=none
ONBOOT=yes
DELAY=0
--------------------
vi /etc/sysconfig/network-scripts/ifcfg-br-vlan424
DEVICE=br-vlan424
TYPE=Bridge
BOOTPROTO=none
ONBOOT=yes
DELAY=0

service network restart

-------------------------------------repo server node 8 --------------------------------------------------------------
----------- server repo ----------------------------
mkdir /localrepo
cp -rv /mnt/* /localrepo/

cd /etc
cp -r yum.repos.d yum.repos.d-bak
rm -rf yum.repos.d/*
vim yum.repos.d/local.repo
[centos7]
name=centos7
baseurl=file:///localrepo/
enabled=1
gpgcheck=0

createrepo /localrepo/
yum clean all
yum repolist all

yum update

yum install httpd
systemctl status httpd
systemctl start httpd
chkconfig httpd on
vi /etc/httpd/conf/httpd.conf
DocumentRoot: "/localrepo"
Options Indexes FollowSymLinks  ---> Options All Indexes FollowSymLinks

rm -rf /etc/httpd/conf.d/welcome.conf
httpd -t
systemctl restart httpd
http://10.38.22.8

----------------------------------------------
systemctl enable httpd
systemctl start httpd
systemctl status httpd
chkconfig httpd on

------ client repo ----------------------------
cp -r /etc/yum.repos.d /etc/yum.repos.d-bak
rm -rf /etc/yum.repos.d/*

vi /etc/yum.repos.d/node8.repo
[yum-node8]
comment ="rh76"
baseurl=http://node8/yum
gpgcheck=0
enabled=1

yum repolist
yum clean all
yum update

------------------------- install tiger VNC ------------------------------------------------------
yum install tigervnc-server
vncserver :0 
pass: admmin123

---------------------- NFS configuration --------------------------------------------------------

--- on VMs client ---
df -kh 
mkdir -p /shared
echo "10.38.22.18:/u01/shared    /shared   nfs defaults 0 0" >> /etc/fstab

mount /shared

df -kh

--------------------------------- tuning VMs Operating ---------------------------------------------
vi /etc/sysctl.conf

# Maximum number of remembered connection requests, which did not yet
# receive an acknowledgment from connecting client.
net.ipv4.tcp_max_syn_backlog =	8192

# Increase the maximum total buffer-space allocatable 
# This is measured in units of pages (4096 bytes) 
net.ipv4.tcp_mem = 2015436 2225152 2539724
net.ipv4.udp_mem = 1887436 2097152 2411724

# Increase the read-buffer space allocatable (minimum size, 
# initial size, and maximum size in bytes)
net.ipv4.tcp_rmem = 4096 262144 16777216

# Increase the write-buffer-space allocatable 
net.ipv4.tcp_wmem = 4096 262144 16777216

net.ipv4.tcp_low_latency = 1

# Increase number of incoming connections backlog queue 
# Sets the maximum number of packets, queued on the INPUT 
# side, when the interface receives packets faster than
# kernel can process them.
net.core.netdev_max_backlog = 250000

# Default Socket Receive Buffer
net.core.rmem_default = 16777216

# Maximum Socket Receive Buffer
net.core.rmem_max = 100663296

# Default Socket Send Buffer 
net.core.wmem_default = 16777216

# Maximum Socket Send Buffer 
net.core.wmem_max = 16777216

# Increase the maximum amount of option memory buffers 
net.core.optmem_max = 16777216

## Decrease swapping ##
vm.swappiness = 0

# Allowed local port range 
net.ipv4.ip_local_port_range = 18000 65535

fs.file-max = 6815744

---------------------------------------------------------------------------
vi /etc/security/limits.conf 
*               soft    nofile               999999
*               hard    nofile               999999

-------------------------------------------------------------
ref:
all options	https://docs.continuent.com/tungsten-clustering-6.0/performance-networking.html
swappiness	https://cloudcraft.info/huong-dan-toi-uu-linux-kernel/
ulimit		https://access.redhat.com/solutions/61334


==============================================================================================
============= mount volume ==================================
---------------node 1 ----------------


mkdir -p /rt-etl2-ssd
mkfs.xfs /dev/mapper/rt-etl2-ssd
mount /dev/mapper/rt-etl2-ssd /rt-etl2-ssd

mkdir -p /rt-etl2-hdd
mkfs.xfs /dev/mapper/rt-etl2-hdd
mount /dev/mapper/rt-etl2-hdd /rt-etl2-hdd

df -kh
echo "/dev/mapper/rt-etl2-ssd       /rt-etl2-ssd    xfs     defaults        0 0" >> /etc/fstab
echo "/dev/mapper/rt-etl2-hdd       /rt-etl2-hdd    xfs     defaults        0 0" >> /etc/fstab

------------- node 2 -----------------------

mkdir -p /rt-oltp-voltdb1-ssd
mkfs.xfs /dev/mapper/rt-oltp-voltdb1-ssd
mount /dev/mapper/rt-oltp-voltdb1-ssd /rt-oltp-voltdb1-ssd

mkdir -p /rt-oltp-voltdb1-hdd
mkfs.xfs /dev/mapper/rt-oltp-voltdb1-hdd
mount /dev/mapper/rt-oltp-voltdb1-hdd /rt-oltp-voltdb1-hdd

mkdir -p /olap-db2-ssd
mkfs.xfs /dev/mapper/olap-db2-ssd
mount /dev/mapper/olap-db2-ssd /olap-db2-ssd

echo "/dev/mapper/rt-oltp-voltdb1-ssd      /rt-oltp-voltdb1-ssd   xfs     defaults        0 0" >> /etc/fstab
echo "/dev/mapper/rt-oltp-voltdb1-hdd      /rt-oltp-voltdb1-hdd    xfs     defaults        0 0" >> /etc/fstab
echo "/dev/mapper/olap-db2-ssd      /olap-db2-ssd   xfs     defaults        0 0" >> /etc/fstab

df -kh
------------------- node 4 ---------------------

mkdir -p /rt-etl1-ssd
mkfs.xfs /dev/mapper/rt-etl1-ssd
mount /dev/mapper/rt-etl1-ssd /rt-etl1-ssd

mkdir -p /rt-etl1-hdd
mkfs.xfs /dev/mapper/rt-etl1-hdd
mount /dev/mapper/rt-etl1-hdd /rt-etl1-hdd

mkdir -p /rt-oltp-voltdb2-ssd
mkfs.xfs /dev/mapper/rt-oltp-voltdb2-ssd
mount /dev/mapper/rt-oltp-voltdb2-ssd /rt-oltp-voltdb2-ssd

mkdir -p /rt-oltp-voltdb2-hdd
mkfs.xfs /dev/mapper/rt-oltp-voltdb2-hdd
mount /dev/mapper/rt-oltp-voltdb2-hdd /rt-oltp-voltdb2-hdd

df -kh
echo "/dev/mapper/rt-etl1-ssd       /rt-etl1-ssd    xfs     defaults        0 0" >> /etc/fstab
echo "/dev/mapper/rt-etl1-hdd       /rt-etl1-hdd    xfs     defaults        0 0" >> /etc/fstab
echo "/dev/mapper/rt-oltp-voltdb2-ssd       /rt-oltp-voltdb2-ssd    xfs     defaults        0 0" >> /etc/fstab
echo "/dev/mapper/rt-oltp-voltdb2-hdd       /rt-oltp-voltdb2-hdd    xfs     defaults        0 0" >> /etc/fstab

cat /etc/fstab 
------------------------ node 6 --------------------

mkdir -p /rt-oltp-voltdb3-ssd
mkfs.xfs /dev/mapper/rt-oltp-voltdb3-ssd
mount /dev/mapper/rt-oltp-voltdb3-ssd /rt-oltp-voltdb3-ssd

mkdir -p /rt-oltp-voltdb3-hdd
mkfs.xfs /dev/mapper/rt-oltp-voltdb3-hdd
mount /dev/mapper/rt-oltp-voltdb3-hdd /rt-oltp-voltdb3-hdd

mkdir -p /olap-db1-ssd
mkfs.xfs /dev/mapper/olap-db1-ssd
mount /dev/mapper/olap-db1-ssd /olap-db1-ssd

mkdir -p /olap-db1-hdd
mkfs.xfs /dev/mapper/olap-db1-hdd
mount /dev/mapper/olap-db1-hdd /olap-db1-hdd
df -kh

echo "/dev/mapper/rt-oltp-voltdb3-ssd       /rt-oltp-voltdb3-ssd    xfs     defaults        0 0" >> /etc/fstab
echo "/dev/mapper/rt-oltp-voltdb3-hdd       /rt-oltp-voltdb3-hdd    xfs     defaults        0 0" >> /etc/fstab
echo "/dev/mapper/olap-db1-ssd       /rt-oltp-voltdb2-ssd    xfs     defaults        0 0" >> /etc/fstab
echo "/dev/mapper/olap-db1-hdd       /olap-db1-hdd    xfs     defaults        0 0" >> /etc/fstab

cat /etc/fstab 

















































































































