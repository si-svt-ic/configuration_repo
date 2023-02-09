===========all password: h@yl4ch1nhb4n ===========================================================================

mount -t iso9660 -o loop /var/lib/libvirt/images/rhel-server-7.6-x86_64-dvd.iso /mnt/
cd /mnt/
cp -ar addons/ /var/www/html/yum/
cd Packages
cp -ar *.*  /var/www/html/yum/

-- node 5, 3, 7 --
scp /etc/yum.repos.d/node8.repo node1:/etc/yum.repos.d/
scp /etc/yum.repos.d/node8.repo node2:/etc/yum.repos.d/
scp /etc/yum.repos.d/node8.repo node3:/etc/yum.repos.d/
scp /etc/yum.repos.d/node8.repo node4:/etc/yum.repos.d/
scp /etc/yum.repos.d/node8.repo node6:/etc/yum.repos.d/
scp /etc/yum.repos.d/node8.repo node7:/etc/yum.repos.d/

# pacemaker - all nodes
yum -y install pacemaker pcs
systemctl start pcsd
systemctl enable pcsd
passwd hacluster
ss -tupln | grep 2224

# run on node5 
pcs cluster auth node5 node8
pcs cluster setup --name clu58 node5 node8
pcs cluster start --all
pcs cluster enable --all;
pcs status cluster;
pcs status corosync

ss -tupln | grep corosync

pcs resource providers
pcs resource agents ocf:heartbeat

# fence : https://redhatlinux.guru/2018/05/19/pacemaker-configure-hp-ilo-4-ssh-fencing/

fence_ilo5_ssh -a 10.38.16.159 -x -l admin -p h@yl4ch1nhb4n -o status

pcs property set no-quorum-policy=freeze 
pcs stonith create node5-ilo5_fence fence_ilo5_ssh ipaddr="10.38.16.159" login="admin" secure="true" passwd=h@yl4ch1nhb4n  pcmk_host_list="node5" op monitor interval=60s
pcs stonith create node8-ilo5_fence fence_ilo5_ssh ipaddr="10.38.16.162" login="admin" secure="true" passwd=h@yl4ch1nhb4n  pcmk_host_list="node8" op monitor interval=60s
#check
corosync-quorumtool 
pcs property show
pcs status
pcs stonith show 

#[6] 	Add required resources. It's OK to set on a node.
https://www.unixarena.com/2016/01/rhel7-configuring-gfs2-on-pacemakercorosync-cluster.html/
https://www.golinuxcloud.com/configure-gfs2-setup-cluster-linux-rhel-centos-7/#Configure_DLM_Resource

lvmconf --enable-cluster;
grep locking_type /etc/lvm/lvm.conf | egrep -v '#'
#reboot
yum -y install fence-agents-all lvm2-cluster gfs2-utils 
pcs property show
#pcs resource delete dlm;
#pcs resource delete clvmd;
pcs resource create dlm ocf:pacemaker:controld op monitor interval=30s on-fail=fence clone interleave=true ordered=true;
pcs resource create clvmd ocf:heartbeat:clvm op monitor interval=30s on-fail=fence clone interleave=true ordered=true;
pcs constraint order start dlm-clone then clvmd-clone;
pcs constraint colocation add clvmd-clone with dlm-clone

# [7] 	Create volumes on shared storage and format with GFS2. It's OK to set on a node. On this example, it is set on sdb and create partitions on it and set LVM type with fdisk.
######### create pv, lv_cluster_hdd cho phân dùng hdd in node5 and node8

# create pv, lv_cluster_hdd cho phân dùng sdd
pvcreate /dev/mapper/clu58-ssd
pvdisplay
# create cluster volume group
vgcreate -cy clu58-ssd_vg /dev/mapper/clu58-ssd
vgdisplay
# create cluster logical volume group 
lvcreate -l100%FREE -n clu58-ssd_lv clu58-ssd_vg
lvdisplay


# create pv, lv_cluster_hdd cho phân dùng hdd
pvcreate /dev/mapper/clu58-hdd
pvdisplay
# create cluster volume group
vgcreate -cy clu58-hdd_vg /dev/mapper/clu58-hdd
vgdisplay
# create cluster logical volume group 
lvcreate -l100%FREE -n clu58-hdd_lv clu58-hdd_vg
lvdisplay
--- mount ---
vi /etc/fstab 
# add lines
/dev/clu58-ssd_vg/clu58-ssd_lv /clu58-ssd gfs2 defaults 0 0 
/dev/clu58-hdd_vg/clu58-hdd_lv /clu58-hdd gfs2 defaults 0 0

mkdir -p /clu58-ssd
mount /clu58-ssd
mkdir -p /clu58-hdd
mount /clu58-hdd
df -h
--- mkfs ---
mkfs.gfs2 -p lock_dlm -t clu58:clu58-sdd -j 2 /dev/clu58-ssd_vg/clu58-ssd_lv
mkfs.gfs2 -p lock_dlm -t clu58:clu58-hdd -j 2 /dev/clu58-hdd_vg/clu58-hdd_lv

--- node8 ---
lvmconf --enable-cluster;
grep locking_type /etc/lvm/lvm.conf | egrep -v '#'
#reboot
yum -y install fence-agents-all lvm2-cluster gfs2-utils 

pvcreate /dev/mapper/clu58-ssd
pvdisplay
# create cluster volume group
vgcreate -cy clu58-ssd_vg /dev/mapper/clu58-ssd
vgdisplay
# create cluster logical volume group 
lvcreate -l100%FREE -n clu58-ssd_lv clu58-ssd_vg
lvdisplay


# create pv, lv_cluster_hdd cho phân dùng hdd
pvcreate /dev/mapper/clu58-hdd
pvdisplay
# create cluster volume group
vgcreate -cy clu58-hdd_vg /dev/mapper/clu58-hdd
vgdisplay
# create cluster logical volume group 
lvcreate -l100%FREE -n clu58-hdd_lv clu58-hdd_vg
lvdisplay


# [8] 	Add shared storage to cluster resource. It's OK to set on a node.
pcs resource create clu58-ssd_res Filesystem \
device="/dev/clu58-ssd_vg/clu58-ssd_lv" directory="/clu58-ssd" fstype="gfs2" \
options="noatime,nodiratime" op monitor interval=10s on-fail=fence clone interleave=true


pcs resource create clu58-hdd_res Filesystem \
device="/dev/clu58-hdd_vg/clu58-hdd_lv" directory="/clu58-hdd" fstype="gfs2" \
options="noatime,nodiratime" op monitor interval=10s on-fail=fence clone interleave=true

-----

pcs resource create fs_gfs2 Filesystem \
device="/dev/vg_cluster/lv_cluster" directory="/disk1" fstype="gfs2" \
options="noatime,nodiratime" op monitor interval=10s on-fail=fence clone interleave=true


pcs resource create data1_gfs2 Filesystem \
device="/dev/vg_cluster/lv_data1" directory="/disk3" fstype="gfs2" \
options="noatime,nodiratime" op monitor interval=10s on-fail=fence clone interleave=true


pcs constraint order start clvmd-clone then fs_gfs2-clone
pcs constraint order start clvmd-clone then data1_gfs2-clone

pcs constraint colocation add fs_gfs2-clone with clvmd-clone
pcs constraint colocation add data1_gfs2-clone with clvmd-clone

pcs constraint show
Location Constraints:
Ordering Constraints:
  start dlm-clone then start clvmd-clone (kind:Mandatory)
  start clvmd-clone then start fs_gfs2-clone (kind:Mandatory)
Colocation Constraints:
  clvmd-clone with dlm-clone (score:INFINITY)
  fs_gfs2-clone with clvmd-clone (score:INFINITY)

pcs resource restart fs_gfs2 --all
pcs resource restart data1_gfs2

# [9] 	It's OK all. Make sure GFS2 filesystem is mounted on an active node and also make sure GFS2 mounts will move to another node if current active node will be down.
[root@node01 ~]# df -hT

Filesystem                        Type      Size  Used Avail Use% Mounted on
/dev/mapper/centos-root           xfs        27G  1.1G   26G   4% /
devtmpfs                          devtmpfs  2.0G     0  2.0G   0% /dev
tmpfs                             tmpfs     2.0G   76M  1.9G   4% /dev/shm
tmpfs                             tmpfs     2.0G  8.4M  2.0G   1% /run
tmpfs                             tmpfs     2.0G     0  2.0G   0% /sys/fs/cgroup
/dev/vda1                         xfs       497M  126M  371M  26% /boot
/dev/mapper/vg_cluster-lv_cluster gfs2     1016M  259M  758M  26% /mnt

echo "`hostname`...`date`" >> /disk1/tiktok.txt;cat /disk1/tiktok.txt
