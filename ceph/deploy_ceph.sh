--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
------------------  CEPH-DEPLOY SETUP ------------------------------------------
###################### install hpssa to make to RAID0 for each hard drive ######################################
[root@node8 ~]# scp hpssa-2.20-11.0.x86_64.rpm 10.38.22.36:/root
[root@node8 ~]# scp hpssa-2.20-11.0.x86_64.rpm 10.38.22.37:/root
[root@node8 ~]# scp hpssa-2.20-11.0.x86_64.rpm 10.38.22.41:/root
[root@node8 ~]# scp hpssa-2.20-11.0.x86_64.rpm 10.38.22.42:/root
[root@node8 ~]# scp hpssa-2.20-11.0.x86_64.rpm 10.38.22.43:/root

[root@ceph01 ~]# cd /root
[root@ceph01 ~]# rpm -ivh hpssa-2.20-11.0.x86_64.rpm 
Preparing...                          ################################# [100%]
Updating / installing...
1:hpssa-2.20-11.0                  ################################# [100%]

Using ilo and run this command on terminal
[root@ceph01 ~]# hpssa -local

##################### tunning operating system on each ceph node ############
vi /etc/sysctl.conf

# The min_free_kbytes setting
vm.min_free_kbytes = 524288
# PIDs wrap around 
# (i.e., the value in this file is one greater than the maximum PID)
kernel.pid_max = 4194303

fs.file-max = 26234859
## Decrease swapping ##
vm.swappiness = 0

# Maximum Socket Receive Buffer
net.core.rmem_max = 56623104

# Maximum Socket Send Buffer 
net.core.wmem_max = 56623104
# Default Socket Receive Buffer
net.core.rmem_default = 56623104

# Default Socket Send Buffer 
net.core.wmem_default = 56623104

# Increase the maximum amount of option memory buffers 
net.core.optmem_max = 40960
# Increase the read-buffer space allocatable (minimum size, 
# initial size, and maximum size in bytes)
net.ipv4.tcp_rmem = 4096 87380 56623104

# Increase the write-buffer-space allocatable 
net.ipv4.tcp_wmem = 4096 65536 56623104

# Make room for more TIME_WAIT sockets due to more clients,
# and allow them to be reused if we run out of sockets
# Also increase the max packet backlog
net.core.somaxconn = 1024

# Increase number of incoming connections backlog queue 
# Sets the maximum number of packets, queued on the INPUT 
# side, when the interface receives packets faster than
# kernel can process them.
net.core.netdev_max_backlog = 50000

# Maximum number of remembered connection requests, which did not yet
# receive an acknowledgment from connecting client.
net.ipv4.tcp_max_syn_backlog =	30000

# Increase the tcp-time-wait buckets pool size to prevent simple DOS attacks
net.ipv4.tcp_max_tw_buckets = 2000000
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
# Decrease the time default value for tcp_fin_timeout connection
net.ipv4.tcp_fin_timeout = 10

# Disable the gradual speed increase that's useful
# on variable-speed WANs but not for us
net.ipv4.tcp_slow_start_after_idle = 0

vi /etc/security/limits.conf 
*               soft    nproc               65535
*               hard    nproc               65535
*               soft    nofile               65535
*               hard    nofile               65535

### Not applicable yet  #######################################################
echo "8192">/sys/block/sda/queue/read_ahead_kb
echo "8192">/sys/block/sdb/queue/read_ahead_kb
echo "8192">/sys/block/sdc/queue/read_ahead_kb
echo "8192">/sys/block/sdd/queue/read_ahead_kb
echo "8192">/sys/block/sde/queue/read_ahead_kb
echo "8192">/sys/block/sdf/queue/read_ahead_kb
echo "8192">/sys/block/sdg/queue/read_ahead_kb
echo "8192">/sys/block/sdh/queue/read_ahead_kb
echo "8192">/sys/block/sdi/queue/read_ahead_kb
echo "8192">/sys/block/sdk/queue/read_ahead_kb
echo "8192">/sys/block/sdl/queue/read_ahead_kb
echo "8192">/sys/block/sdm/queue/read_ahead_kb

# for SATA/ SAS, default = deadline
[root@ceph01 ~]# cat /sys/block/sda/queue/scheduler              
noop [deadline] cfq 

echo "deadline" > /sys/block/sda/queue/scheduler
# for SSD 
echo "noop" > /sys/block/sdl/queue/scheduler 
echo "noop" > /sys/block/sdm/queue/scheduler 

reboot
#################################################################################

[root@ceph01 ~]# scp /etc/sysctl.conf ceph02:/etc/sysctl.conf
[root@ceph01 ~]# scp /etc/sysctl.conf ceph03:/etc/sysctl.conf
[root@ceph01 ~]# scp /etc/security/limits.conf ceph02:/etc/security/limits.conf
[root@ceph01 ~]# scp /etc/security/limits.conf ceph03:/etc/security/limits.conf

###############################################################################################
####################### step 1 : Prelight #####################################################
### all node ###
systemctl stop firewalld
vi /etc/selinux/config
SELINUX=disabled

vi /etc/hosts
[root@ceph01 ~]# cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
# vlan 427 - api - management

10.38.22.17 node7
10.38.22.34 lb01
10.38.22.35 lb02
10.38.22.30 controller
10.38.22.31 controller01
10.38.22.32 controller02
10.38.22.33 controller03
10.38.22.36 compute01
10.38.22.37 compute02
10.38.22.41 ceph01
10.38.22.42 ceph02
10.38.22.43 ceph03

# vlan 420 - internal: storage, tunnel, ceph public 

192.168.100.7 node7.internal
192.168.100.31 controller01.internal
192.168.100.32 controller02.internal
192.168.100.33 controller03.internal
192.168.100.36 compute01.internal
192.168.100.37 compute02.internal
192.168.100.41 ceph01.internal
192.168.100.42 ceph02.internal
192.168.100.43 ceph03.internal

# vlan 2 - ceph cluster

172.16.0.41 ceph01.cluster
172.16.0.42 ceph02.cluster
172.16.0.43 ceph03.cluster

### on ceph01, add repo on all node ###
yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
vi /etc/yum.repos.d/ceph.repo 

[ceph]
name=Ceph packages for $basearch
baseurl=https://download.ceph.com/rpm-nautilus/el7/x86_64/
enabled=1
priority=2
gpgcheck=1
gpgkey=https://download.ceph.com/keys/release.asc

[ceph-noarch]
name=Ceph noarch packages
baseurl=https://download.ceph.com/rpm-nautilus/el7/noarch
enabled=1
priority=2
gpgcheck=1
gpgkey=https://download.ceph.com/keys/release.asc

[ceph-source]
name=Ceph source packages
baseurl=https://download.ceph.com/rpm-nautilus/el7/SRPMS
enabled=0
priority=2
gpgcheck=1
gpgkey=https://download.ceph.com/keys/release.asc

yum -y update
yum -y install ceph-deploy


----------------CEPH NODE SETUP ----------------------------------------------------------
# all node 
### INSTALL NTP

### INSTALL SSH SERVER ( all ceph node ) 
yum -y install openssh-server

useradd -d /home/cephuser -m cephuser
passwd cephuser
### cephuser/admin123 ###

echo "cephuser ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/cephuser
chmod 0440 /etc/sudoers.d/cephuser
sed -i s'/Defaults requiretty/#Defaults requiretty'/g /etc/sudoers

### ENABLE PASSWORD-LESS SSH on ceph01 ###
su - cephuser

ssh-keygen

vi ~/.ssh/config

Host ceph01
        Hostname ceph01.internal
        User cephuser
        SendEnv http_proxy https_proxy
Host ceph02
        Hostname ceph02.internal
        User cephuser
        SendEnv http_proxy https_proxy
Host ceph03
        Hostname ceph03.internal
        User cephuser
        SendEnv http_proxy https_proxy

chmod 644 ~/.ssh/config

ssh-keyscan ceph01.internal ceph02.internal ceph03.internal >> ~/.ssh/known_hosts

ssh-copy-id ceph01.internal
ssh-copy-id ceph02.internal
ssh-copy-id ceph03.internal

### OPEN REQUIRED PORTS
### log-in cephuser on admin-node node ###

systemctl start firewalld
systemctl enable firewalld

firewall-cmd --zone=public --add-port=80/tcp --permanent
firewall-cmd --zone=public --add-port=2003/tcp --permanent
firewall-cmd --zone=public --add-port=4505-4506/tcp --permanent
firewall-cmd --reload

ssh node1
systemctl start firewalld
systemctl enable firewalld
firewall-cmd --zone=public --add-port=6789/tcp --permanent
firewall-cmd --zone=public --add-port=6800-7300/tcp --permanent
firewall-cmd --reload
exit

ssh node2
systemctl start firewalld
systemctl enable firewalld
firewall-cmd --zone=public --add-port=6800-7300/tcp --permanent
firewall-cmd --reload
exit

ssh node3
systemctl start firewalld
systemctl enable firewalld
firewall-cmd --zone=public --add-port=6800-7300/tcp --permanent
firewall-cmd --reload
exit

### PRIORITIES/PREFERENCES
# for all node #

yum -y install yum-plugin-priorities

================ step 2:  STORAGE CLUSTER QUICK START ####################################
# on ceph01 , using cephuser user
su - cephuser
mkdir cluster
cd cluster/

### CREATE A CLUSTER
ceph-deploy new ceph01.internal ceph02.internal ceph03.internal

vi ceph.conf
[global]
fsid = abd008ce-1ab0-423a-8b64-83a83ecd9fa0
mon_initial_members = ceph01, ceph02, ceph03
mon_host = 192.168.100.41,192.168.100.42,192.168.100.43
auth_cluster_required = cephx
auth_service_required = cephx
auth_client_required = cephx
# object replication
osd pool default size = 3
osd pool default min size = 2
osd pool default pg num = 1024
osd pool default pgp num = 1024
# network 
public network = 192.168.100.0/24
cluster network = 172.16.0.0/24
	
[mon]
mon allow pool delete = true
mon clock drift allowed = 10
[mon.0]
host = ceph01.internal
mon addr = 192.168.100.41:6789
mgr initial modules = dashboard
[mon.1]
host = ceph02.internal
mon addr = 192.168.100.42:6789
[mon.2]
host = ceph03.internal
mon addr = 192.168.100.43:6789

[osd]
bluestore_cache_size_hdd = 1G
bluestore_cache_size_ssd = 8G
osd recovery op priority = 4
osd recovery max active = 10
osd max backfills = 4
osd max write size = 512
osd client message size cap = 2147483648
osd deep scrub stride = 131072
osd op threads = 8
osd disk threads =4
osd map cache size = 1024
osd map cache bl size = 128

[client]
rbd cache = true
rbd cache size = 268435456
rbd cache max dirty =  134217728
rbd cache max dirty age = 5
	
### config proxy for all yum command ###
# on ceph01
[cephuser@ceph01 cluster]$ cat ~/.ssh/config 
Host ceph01
        Hostname ceph01
        User cephuser
        SendEnv http_proxy https_proxy
Host ceph02
        Hostname ceph02
        User cephuser 
        SendEnv http_proxy https_proxy
Host ceph03
        Hostname ceph03
        User cephuser
        SendEnv http_proxy https_proxy

# on  ceph01, ceph02, ceph03 		
vi cat ~/.bash_profile 
export http_proxy=http://10.3.60.168:3128
export https_proxy=$http_proxy

vi /etc/ssh/sshd_config
PermitUserEnvironment yes
AcceptEnv https_proxy http_proxy

vi /etc/sudoers
Defaults    env_keep += "ftp_proxy http_proxy https_proxy no_proxy"

## deploy on all ceph node, using cephuer ##
ceph-deploy install --release nautilus ceph01 ceph02 ceph03
ceph-deploy mon create-initial
ceph-deploy admin ceph01 ceph02 ceph03


sudo ssh ceph01 sudo chmod +r /etc/ceph/ceph.client.admin.keyring
sudo ssh ceph02 sudo chmod +r /etc/ceph/ceph.client.admin.keyring
sudo ssh ceph03 sudo chmod +r /etc/ceph/ceph.client.admin.keyring

ceph-deploy mgr create ceph01 ceph02 ceph03

### create raid 0 for each hard drive ( 10 HDD + 2 SSD ) #
#### on call node, using root user ###

vgcreate ceph-block-0 /dev/sdb
vgcreate ceph-block-1 /dev/sdc
vgcreate ceph-block-2 /dev/sdd
vgcreate ceph-block-3 /dev/sde
vgcreate ceph-block-4 /dev/sdf
vgcreate ceph-block-5 /dev/sdg
vgcreate ceph-block-6 /dev/sdh
vgcreate ceph-block-7 /dev/sdi
vgcreate ceph-block-8 /dev/sdj
vgcreate ceph-block-9 /dev/sdk

vgcreate ceph-db-0 /dev/sdl
vgcreate ceph-db-1 /dev/sdm

lvcreate -l 100%FREE -n block-0 ceph-block-0
lvcreate -l 100%FREE -n block-1 ceph-block-1
lvcreate -l 100%FREE -n block-2 ceph-block-2
lvcreate -l 100%FREE -n block-3 ceph-block-3
lvcreate -l 100%FREE -n block-4 ceph-block-4
lvcreate -l 100%FREE -n block-5 ceph-block-5
lvcreate -l 100%FREE -n block-6 ceph-block-6
lvcreate -l 100%FREE -n block-7 ceph-block-7
lvcreate -l 100%FREE -n block-8 ceph-block-8
lvcreate -l 100%FREE -n block-9 ceph-block-9

lvcreate -L 150GB -n db-0 ceph-db-0
lvcreate -L 150GB -n db-1 ceph-db-0
lvcreate -L 150GB -n db-2 ceph-db-0
lvcreate -L 150GB -n db-3 ceph-db-0
lvcreate -L 150GB -n db-4 ceph-db-0

lvcreate -L 150GB -n db-5 ceph-db-1
lvcreate -L 150GB -n db-6 ceph-db-1
lvcreate -L 150GB -n db-7 ceph-db-1
lvcreate -L 150GB -n db-8 ceph-db-1
lvcreate -L 150GB -n db-9 ceph-db-1

##### on ceph01 , using root ###
su - cephuser
cd /cluster

ceph-deploy osd create --bluestore --block-db ceph-db-0/db-0 --data ceph-block-0/block-0 ceph01
ceph-deploy osd create --bluestore --block-db ceph-db-0/db-1 --data ceph-block-1/block-1 ceph01
ceph-deploy osd create --bluestore --block-db ceph-db-0/db-2 --data ceph-block-2/block-2 ceph01
ceph-deploy osd create --bluestore --block-db ceph-db-0/db-3 --data ceph-block-3/block-3 ceph01
ceph-deploy osd create --bluestore --block-db ceph-db-0/db-4 --data ceph-block-4/block-4 ceph01

ceph-deploy osd create --bluestore --block-db ceph-db-1/db-5 --data ceph-block-5/block-5 ceph01
ceph-deploy osd create --bluestore --block-db ceph-db-1/db-6 --data ceph-block-6/block-6 ceph01
ceph-deploy osd create --bluestore --block-db ceph-db-1/db-7 --data ceph-block-7/block-7 ceph01
ceph-deploy osd create --bluestore --block-db ceph-db-1/db-8 --data ceph-block-8/block-8 ceph01
ceph-deploy osd create --bluestore --block-db ceph-db-1/db-9 --data ceph-block-9/block-9 ceph01

ceph-deploy osd create --bluestore --block-db ceph-db-0/db-0 --data ceph-block-0/block-0 ceph02
ceph-deploy osd create --bluestore --block-db ceph-db-0/db-1 --data ceph-block-1/block-1 ceph02
ceph-deploy osd create --bluestore --block-db ceph-db-0/db-2 --data ceph-block-2/block-2 ceph02
ceph-deploy osd create --bluestore --block-db ceph-db-0/db-3 --data ceph-block-3/block-3 ceph02
ceph-deploy osd create --bluestore --block-db ceph-db-0/db-4 --data ceph-block-4/block-4 ceph02
																								  
ceph-deploy osd create --bluestore --block-db ceph-db-1/db-5 --data ceph-block-5/block-5 ceph02
ceph-deploy osd create --bluestore --block-db ceph-db-1/db-6 --data ceph-block-6/block-6 ceph02
ceph-deploy osd create --bluestore --block-db ceph-db-1/db-7 --data ceph-block-7/block-7 ceph02
ceph-deploy osd create --bluestore --block-db ceph-db-1/db-8 --data ceph-block-8/block-8 ceph02
ceph-deploy osd create --bluestore --block-db ceph-db-1/db-9 --data ceph-block-9/block-9 ceph02

ceph-deploy osd create --bluestore --block-db ceph-db-0/db-0 --data ceph-block-0/block-0 ceph03
ceph-deploy osd create --bluestore --block-db ceph-db-0/db-1 --data ceph-block-1/block-1 ceph03
ceph-deploy osd create --bluestore --block-db ceph-db-0/db-2 --data ceph-block-2/block-2 ceph03
ceph-deploy osd create --bluestore --block-db ceph-db-0/db-3 --data ceph-block-3/block-3 ceph03
ceph-deploy osd create --bluestore --block-db ceph-db-0/db-4 --data ceph-block-4/block-4 ceph03
																								   
ceph-deploy osd create --bluestore --block-db ceph-db-1/db-5 --data ceph-block-5/block-5 ceph03
ceph-deploy osd create --bluestore --block-db ceph-db-1/db-6 --data ceph-block-6/block-6 ceph03
ceph-deploy osd create --bluestore --block-db ceph-db-1/db-7 --data ceph-block-7/block-7 ceph03
ceph-deploy osd create --bluestore --block-db ceph-db-1/db-8 --data ceph-block-8/block-8 ceph03
ceph-deploy osd create --bluestore --block-db ceph-db-1/db-9 --data ceph-block-9/block-9 ceph03

# check health
sudo ceph health
sudo ceph -s

### EXPANDING YOUR CLUSTER ###

# ADD A METADATA SERVER --> node1
ceph-deploy mds create ceph01

#check quorum_status
sudo ceph quorum_status --format json-pretty

# ADDING MANAGERS
ceph-deploy mgr create ceph02 ceph03
sudo ceph -s

# ADD AN RGW INSTANCE
ceph-deploy rgw create ceph01
################################### install dashboard for ceph # #############################
yum -y install ceph-mgr-dashboard

### enable ###
ceph mgr module enable dashboard --force

### config ###
ceph dashboard create-self-signed-cert

openssl req -new -nodes -x509 \
  -subj "/O=IT/CN=ceph-mgr-dashboard" -days 3650 \
  -keyout dashboard.key -out dashboard.crt -extensions v3_ca

ceph config-key set mgr mgr/dashboard/crt -i dashboard.crt
ceph config-key set mgr mgr/dashboard/key -i dashboard.key

### if need ##
ceph config-key set mgr/dashboard/ceph_admin/crt -i dashboard.crt
ceph config-key set mgr/dashboard/ceph_admin/key -i dashboard.key

ceph config set mgr mgr/dashboard/ssl false

### set ip and port ###
ceph config set mgr mgr/dashboard/server_addr 10.38.22.41
ceph config set mgr mgr/dashboard/server_port 7000

### account ###
ceph dashboard set-login-credentials admin h@yl4ch1nhb4n

### restart ###
ceph mgr module disable dashboard
ceph mgr module enable dashboard

## test
	http://http://10.38.22.41:7000


#################################################################################################
#################################################################################################
################## integrate OPENSTACK TRAIN ###################################################

##### 1. On Controller, Compute1, Compute2 : instack the packages for Ceph #####
# using root user
yum install -y yum-utils
yum-config-manager --add-repo https://dl.fedoraproject.org/pub/epel/7/x86_64/ 
yum install --nogpgcheck -y epel-release 
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7 
rm /etc/yum.repos.d/dl.fedoraproject.org*

vi /etc/yum.repos.d/ceph.repo 

[ceph]
name=Ceph packages for $basearch
baseurl=https://download.ceph.com/rpm-nautilus/el7/x86_64/
enabled=1
priority=2
gpgcheck=1
gpgkey=https://download.ceph.com/keys/release.asc

[ceph-noarch]
name=Ceph noarch packages
baseurl=https://download.ceph.com/rpm-nautilus/el7/noarch
enabled=1
priority=2
gpgcheck=1
gpgkey=https://download.ceph.com/keys/release.asc

[ceph-source]
name=Ceph source packages
baseurl=https://download.ceph.com/rpm-nautilus/el7/SRPMS
enabled=0
priority=2
gpgcheck=1
gpgkey=https://download.ceph.com/keys/release.asc

yum -y update
yum -y install python-rbd ceph-common

##### 2. On Ceph1 ######

### create the pools for openstack service , pool default size 1024 pg #
ceph osd pool create volumes 1024 
ceph osd pool create vms 1024

### copy config file & admin key --> Controller 1-2-3 & Compute 1-2
# on Ceph ceph01
su - cephuser
cd cluster/
ceph-deploy admin root@controller0{1..3}
ceph-deploy admin root@compute0{1..2}

# Copy /etc/ceph/ to controller 1-2-3 & Compute1-2
su - cephuser
cd cluster/
sudo scp -r /etc/ceph/ root@controller0{1..3}:/etc/ceph/
sudo scp -r /etc/ceph/ root@compute0{1..2}:/etc/ceph/

# Create Ceph user for Openstack ( on ceph admin-node)
sudo ceph auth get-or-create client.glance mon 'allow r' osd 'allow class-read object_prefix rbd_children, allow rwx pool=images'
sudo ceph auth get-or-create client.cinder-backup mon 'allow r' osd 'allow class-read object_prefix rbd_children, allow rwx pool=backups'
sudo ceph auth get-or-create client.cinder mon 'allow r' osd 'allow class-read object_prefix rbd_children, allow rwx pool=volumes, allow rwx pool=vms, allow rwx pool=images'

# Copy key --> Controller1-2-3

sudo ceph auth get-or-create client.glance | ssh root@controller01 sudo tee /etc/ceph/ceph.client.glance.keyring
sudo ssh root@controller01 chown glance:glance /etc/ceph/ceph.client.glance.keyring
sudo ceph auth get-or-create client.cinder | ssh root@controller01 sudo tee /etc/ceph/ceph.client.cinder.keyring
sudo ssh root@controller01 chown cinder:cinder /etc/ceph/ceph.client.cinder.keyring
sudo ceph auth get-or-create client.cinder-backup | ssh root@controller01 sudo tee /etc/ceph/ceph.client.cinder-backup.keyring
sudo ssh root@controller01 chown cinder:cinder /etc/ceph/ceph.client.cinder-backup.keyring

sudo ceph auth get-or-create client.glance | ssh root@controller02 sudo tee /etc/ceph/ceph.client.glance.keyring
sudo ssh root@controller02 chown glance:glance /etc/ceph/ceph.client.glance.keyring
sudo ceph auth get-or-create client.cinder | ssh root@controller02 sudo tee /etc/ceph/ceph.client.cinder.keyring
sudo ssh root@controller02 chown cinder:cinder /etc/ceph/ceph.client.cinder.keyring
sudo ceph auth get-or-create client.cinder-backup | ssh root@controller02 sudo tee /etc/ceph/ceph.client.cinder-backup.keyring
sudo ssh root@controller02 chown cinder:cinder /etc/ceph/ceph.client.cinder-backup.keyring

sudo ceph auth get-or-create client.glance | ssh root@controller03 sudo tee /etc/ceph/ceph.client.glance.keyring
sudo ssh root@controller03 chown glance:glance /etc/ceph/ceph.client.glance.keyring
sudo ceph auth get-or-create client.cinder | ssh root@controller03 sudo tee /etc/ceph/ceph.client.cinder.keyring
sudo ssh root@controller03 chown cinder:cinder /etc/ceph/ceph.client.cinder.keyring
sudo ceph auth get-or-create client.cinder-backup | ssh root@controller03 sudo tee /etc/ceph/ceph.client.cinder-backup.keyring
sudo ssh root@controller03 chown cinder:cinder /etc/ceph/ceph.client.cinder-backup.keyring

# Copy key client.cinder --> Compute1-2

sudo ceph auth get-or-create client.cinder | ssh root@compute01 sudo tee /etc/ceph/ceph.client.cinder.keyring
sudo ceph auth get-key client.cinder | ssh root@compute01 tee /root/client.cinder.key

sudo ceph auth get-or-create client.cinder | ssh root@compute02 sudo tee /etc/ceph/ceph.client.cinder.keyring
sudo ceph auth get-key client.cinder | ssh root@compute02 tee /root/client.cinder.key

##### 3. Controller01 node #####

# 3.1 Create secret key for attach the volumes to VMs, using root user
uuidgen
# uuid
5c778d4e-2d9a-4227-9d4f-cc1729c64b65

# 3.3 Config /etc/cinder/cinder.conf on Controller01-2-3 for save volume & volume backup to Ceph
# use uuid in stp 3.1
vi /etc/cinder/cinder.conf
[DEFAULT]
...
enabled_backends=ceph

[ceph]
volume_backend_name=ceph
volume_driver=cinder.volume.drivers.rbd.RBDDriver
rbd_pool=volumes
rbd_ceph_conf=/etc/ceph/ceph.conf
rbd_flatten_volume_from_snapshot=false
rbd_max_clone_depth=5
rbd_store_chunk_size = 4
rados_connect_timeout = -1
rbd_user=cinder
rbd_secret_uuid=5c778d4e-2d9a-4227-9d4f-cc1729c64b65

# 3.4 Restart services
systemctl restart openstack-cinder-api.service openstack-cinder-scheduler.service openstack-cinder-volume.service	
systemctl enable openstack-cinder-volume.service
# check
[root@controller01 ~(keystone)]# openstack volume service list
+------------------+-------------------+------+---------+-------+----------------------------+
| Binary           | Host              | Zone | Status  | State | Updated At                 |
+------------------+-------------------+------+---------+-------+----------------------------+
| cinder-scheduler | controller01      | nova | enabled | up    | 2019-12-06T16:00:53.000000 |
| cinder-scheduler | controller02      | nova | enabled | up    | 2019-12-06T16:01:01.000000 |
| cinder-scheduler | controller03      | nova | enabled | up    | 2019-12-06T16:00:58.000000 |
| cinder-volume    | controller01@ceph | nova | enabled | up    | 2019-12-06T16:01:00.000000 |
+------------------+-------------------+------+---------+-------+----------------------------+

###### 4. On node Compute01 ######
# 4.1. Config /etc/nova/nova.conf to save VMs to Ceph
vi /etc/nova/nova.conf

[libvirt]
images_type = rbd
images_rbd_pool = vms
images_rbd_ceph_conf = /etc/ceph/ceph.conf
rbd_user = cinder
rbd_secret_uuid = 5c778d4e-2d9a-4227-9d4f-cc1729c64b65
disk_cachemodes="network=writeback"
hw_disk_discard = unmap 
live_migration_flag= "VIR_MIGRATE_UNDEFINE_SOURCE,VIR_MIGRATE_PEER2PEER,VIR_MIGRATE_LIVE,VIR_MIGRATE_PERSIST_DEST,VIR_MIGRATE_TUNNELLED"
#inject_password = false
#inject_key = false
#inject_partition = -2

# 4.2. Add secret key to libvirt

cd /root
cat > secret.xml <<EOF
<secret ephemeral='no' private='no'>
  <uuid>5c778d4e-2d9a-4227-9d4f-cc1729c64b65
</uuid>
  <usage type='ceph'>
    <name>client.cinder secret</name>
  </usage>
</secret>
EOF

virsh secret-define --file /root/secret.xml
#Secret 5c778d4e-2d9a-4227-9d4f-cc1729c64b65 created

sudo virsh secret-set-value --secret 5c778d4e-2d9a-4227-9d4f-cc1729c64b65 --base64 $(cat client.cinder.key)
###### 4. On node Compute02 ######
# 4.1. Config /etc/nova/nova.conf to save VMs to Ceph
vi /etc/nova/nova.conf

[libvirt]
images_type = rbd
images_rbd_pool = vms
images_rbd_ceph_conf = /etc/ceph/ceph.conf
rbd_user = cinder
rbd_secret_uuid = 5c778d4e-2d9a-4227-9d4f-cc1729c64b65
disk_cachemodes="network=writeback"
hw_disk_discard = unmap 
live_migration_flag= "VIR_MIGRATE_UNDEFINE_SOURCE,VIR_MIGRATE_PEER2PEER,VIR_MIGRATE_LIVE,VIR_MIGRATE_PERSIST_DEST,VIR_MIGRATE_TUNNELLED"
#inject_password = false
#inject_key = false
#inject_partition = -2

# 4.2. Add secret key to libvirt

cd /root
cat > secret.xml <<EOF
<secret ephemeral='no' private='no'>
  <uuid>5c778d4e-2d9a-4227-9d4f-cc1729c64b65
</uuid>
  <usage type='ceph'>
    <name>client.cinder secret</name>
  </usage>
</secret>
EOF

virsh secret-define --file /root/secret.xml
Secret 5c778d4e-2d9a-4227-9d4f-cc1729c64b65 created

sudo virsh secret-set-value --secret 5c778d4e-2d9a-4227-9d4f-cc1729c64b65 --base64 $(cat client.cinder.key)

# 4.3 Restart services
systemctl restart libvirtd.service openstack-nova-compute.service

###### 5. Test ######
### 5.1 Test Cinder
# on Controller create a Volume
openstack volume create --size 10 volume-test-after-integrate-2
# on Ceph check new rbd-volume 
[cephuser@ceph01 cluster]$ rbd -p volumes ls

### 5.2 Test Nova
# on dashboard openstack , create new VMs
# check on Ceph
[cephuser@ceph01 cluster]$  rbd ls -p vms 
e12cda02-20cc-4b8b-af20-d69727fc0fac_disk

#### install vnc ###
yum -y install vnc-server
vncserver :1

#pass: admin123

############# remove osd if need ################################################

[cephuser@ceph01 cluster]$ ceph osd tree
ID CLASS WEIGHT  TYPE NAME       STATUS REWEIGHT PRI-AFF 
-1       1.38458 root default                            
-3       1.38458     host ceph01                         
 1   hdd 0.69229         osd.1       up        0 1.00000 
 2   hdd 0.69229         osd.2       up  1.00000 1.00000 
 
[cephuser@ceph01 cluster]$ ceph osd out 1
[cephuser@ceph01 cluster]$ sudo systemctl stop ceph-osd@1
[cephuser@ceph01 cluster]$ ceph osd purge 1 --yes-i-really-mean-it

[cephuser@ceph01 cluster]$ ceph osd tree
ID CLASS WEIGHT  TYPE NAME       STATUS REWEIGHT PRI-AFF 
-1       0.69229 root default                            
-3       0.69229     host ceph01                         
 2   hdd 0.69229         osd.2       up  1.00000 1.00000 
 
 
[cephuser@ceph01 cluster]$ sudo ceph-volume lvm zap ceph-db-0/db-0

[cephuser@ceph01 cluster]$ sudo ceph-volume lvm zap ceph-block-0/block-0
 
####### uninstall ceph if need ################################################
ceph-deploy uninstall ceph01 ceph02 ceph03

ceph-deploy purgedata ceph01 ceph02 ceph03

ceph-deploy purge ceph01 ceph02 ceph03

cd cluster/ 
rm -rf all_file_in_it

############# edit parameter on ceph #########
### remove pg_num and pgp_num

[cephuser@ceph01 cluster]$ sudo vi /etc/ceph/ceph.conf
# remove config
sudo scp /etc/ceph/ceph.conf ceph02:/etc/ceph/ceph.conf  
sudo scp /etc/ceph/ceph.conf ceph03:/etc/ceph/ceph.conf  

[cephuser@ceph01 cluster]$ cd cluster/
[cephuser@ceph01 cluster]$ ceph-deploy --overwrite-conf config push ceph0{1..3}

[cephuser@ceph01 cluster]$ sudo systemctl | grep mon 
[cephuser@ceph01 cluster]$ sudo systemctl restart ceph-mon@ceph01.service   
[cephuser@ceph01 cluster]$ sudo ssh ceph02 systemctl restart ceph-mon@ceph02.service
[cephuser@ceph01 cluster]$ sudo ssh ceph03 systemctl restart ceph-mon@ceph03.service

#### delete pool 

[cephuser@ceph01 cluster]$ ceph osd lspools 
1 .rgw.root
2 default.rgw.control
3 test

[cephuser@ceph01 cluster]$ ceph osd pool delete test test --yes-i-really-really-mean-it
[cephuser@ceph01 cluster]$ ceph osd pool delete default.rgw.control default.rgw.control --yes-i-really-really-mean-it
[cephuser@ceph01 cluster]$ ceph osd pool delete .rgw.root .rgw.root --yes-i-really-really-mean-i

### create vg, lv on compute1, 2 to using hdd local, ssd local and mount to save vm to local#
[root@compute01 ~]# vgcreate local-hdd-vg /dev/sdb
[root@compute01 ~]# lvcreate -l 100%FREE -n local-hdd-lv local-hdd-vg  

[root@compute01 ~]# vgcreate local-ssd-vg /dev/sdc 
[root@compute01 ~]# lvcreate -l 100%FREE -n local-ssd-lv local-ssd-vg 
[root@compute01 ~]# vgs
[root@compute01 ~]# lvs
[root@compute01 ~]# mkfs.xfs /dev/local-hdd-vg/local-hdd-lv 
[root@compute01 ~]# mkfs.xfs /dev/local-ssd-vg/local-ssd-lv
 
# stop all instances on dashboard
 
systemctl start libvirtd.service openstack-nova-compute.service

# enable volume application [cephfs,rbd,rgw] 

[cephuser@ceph01 cluster]$ ceph osd pool application enable volumes rbd
enabled application 'rbd' on pool 'volumes'
[cephuser@ceph01 cluster]$ ceph osd pool application enable vms rbd    
enabled application 'rbd' on pool 'vms'
[cephuser@ceph01 cluster]$ 


################ CEPH dashboard via Haproxy      #############################
# install ceph-mgr-dashboard on ceph02, ceph03
yum -y install ceph-mgr-dashboard

ceph config set mgr mgr/dashboard/ceph01/server_addr 10.38.22.41
ceph config set mgr mgr/dashboard/ceph01/server_port 7000
systemctl restart ceph-mgr@ceph01.service

ceph config set mgr mgr/dashboard/ceph02/server_addr 10.38.22.42
ceph config set mgr mgr/dashboard/ceph02/server_port 7000
systemctl restart ceph-mgr@ceph02.service

ceph config set mgr mgr/dashboard/ceph03/server_addr 10.38.22.43
ceph config set mgr mgr/dashboard/ceph03/server_port 7000
systemctl restart ceph-mgr@ceph03.service

# (1) disable the redirection
ceph config set mgr mgr/dashboard/standby_behaviour "error"
# (2) config error code
ceph config set mgr mgr/dashboard/standby_error_status_code 503
# disable ssl
ceph config set mgr mgr/dashboard/ssl false

# (3) config in haproxy.conf on LB01, LB02
defaults
  ...

frontend ceph-dashboard-frontend
  bind 10.38.22.30:7000
  default_backend ceph-dashboard

backend ceph-dashboard
  balance roundrobin
  option httpchk GET /
  http-check expect status 200
  server ceph01 10.38.22.41:7000 check
  server ceph02 10.38.22.42:7000 check
  server ceph03 10.38.22.43:7000 check

systemctl restart haproxy.service
  
----------------
# check
	ceph mgr services 

# reference: 
# https://blog.widodh.nl/2019/01/haproxy-in-front-of-ceph-manager-dashboard/
# https://docs.ceph.com/docs/master/mgr/dashboard/c
# 


