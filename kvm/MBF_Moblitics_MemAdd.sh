
######################################### MBF-Mobilitic 01 - OCT - 2019 #####################################
####### all password: h@yl4ch1nhb4n ##############

# node 3-7-5-8
lvmconf --enable-cluster;
grep locking_type /etc/lvm/lvm.conf | egrep -v '#'

# node 1->6 
virsh list -all
virsh shutdown vm_id

### Lap ram  1->6
### power ON node 1->6
### set thong so ve RAM all node( use GUI)
### Start VM node1,2,4,6 (on GUI)

# node 8

virsh dumpxml db_mssp > /root/db_mssp.xml
virsh dumpxml home_mssp > /root/home_mssp.xml
virsh dumpxml pmbh > /root/pmbh.xml

virsh define /root/db_mssp.xml
virsh define /root/home_mssp.xml
virsh define /root/pmbh.xml
virsh list --all --persistent

# node 7
virsh dumpxml me_mssp > /root/me_mssp.xml
virsh dumpxml ae_mssp > /root/ae_mssp.xml

virsh define /root/me_mssp.xml	
virsh define /root/ae_mssp.xml	
virsh list --all --persistent

# node 7-8 
virsh list -all
virsh shutdown vm_id

### Edit /u01 -> /var/lib/libvirt/images ####
# node 7

mv /u01/db_mssp_bk.qcow2 /var/lib/libvirt/images/db_mssp_bk.qcow2
virsh edit db_mssp_bk

mv /u01/mshop_web-ssd1.qcow2 /var/lib/libvirt/images/mshop_web-ssd.qcow2
virsh edit mshop_web

mv /u01/mshop_app-ssd1.qcow2 /var/lib/libvirt/images/mshop_app-ssd.qcow2
virsh edit mshop_app

### Shutdown node 7-8
### Lap ram node 7-8
### set thong so ve RAM all node( on GUI)
### Start VM node7,8 ( on GUI)

######################### Cai GFS2 ########################

##################################################### CLU58 ######################################################

# [I]  xoa resource trong cluster tu truoc
# kiem tra cluster hien tai da cau hinh
pcs cluster status

# list reourse da cau hinh
pcs resource show

#xoa resource
#pcs resource delete [resource id]
pcs resource delete dlm;
pcs resource delete clvmd;
	
#kiem tra lai cluster cu he thong
pcs cluster status

# [II] xoa lv, vg,pv da tao tu truoc
#create on node5
pcs resource create dlm ocf:pacemaker:controld op monitor interval=30s on-fail=fence clone interleave=true ordered=true;
pcs resource create clvmd ocf:heartbeat:clvm op monitor interval=30s on-fail=fence clone interleave=true ordered=true;
pcs constraint order start dlm-clone then clvmd-clone;
pcs constraint colocation add clvmd-clone with dlm-clone
# xoa logical volume on node5 and node8
pvs
vgremove clu58-ssd_vg
vgremove clu58-hdd_vg

# xoa physical volume on node5
pvs
pvremove /dev/mapper/clu58-ssd
pvremove /dev/mapper/clu58-hdd

# [III] tao lai resourse cluster
# check on node5 and node8
lvmconf --enable-cluster;
grep locking_type /etc/lvm/lvm.conf | egrep -v '#'
locking_type = 3

# [IV] Tao lai pv, vg, lv on node05
#cho phan cung ssd
pvcreate /dev/mapper/clu58-ssd
pvdisplay
vgcreate -cy clu58-ssd_vg /dev/mapper/clu58-ssd
vgdisplay
lvcreate -l100%FREE -n clu58-ssd_lv clu58-ssd_vg
lvdisplay

#cho phan cung hdd
pvcreate /dev/mapper/clu58-hdd
pvdisplay
vgcreate -cy clu58-hdd_vg /dev/mapper/clu58-hdd
vgdisplay
lvcreate -l100%FREE -n clu58-hdd_lv clu58-hdd_vg
lvdisplay

--- mount to test--- on node5, node8 

# vi /etc/fstab 
/dev/clu58-ssd_vg/clu58-ssd_lv /clu58-ssd gfs2 defaults 0 0 
/dev/clu58-hdd_vg/clu58-hdd_lv /clu58-hdd gfs2 defaults 0 0

# --- mkfs ---
mkfs.gfs2 -p lock_dlm -t clu58:clu58-sdd -j 2 /dev/clu58-ssd_vg/clu58-ssd_lv
mkfs.gfs2 -p lock_dlm -t clu58:clu58-hdd -j 2 /dev/clu58-hdd_vg/clu58-hdd_lv

mkdir -p /clu58-ssd
mount /clu58-ssd
mkdir -p /clu58-hdd
mount /clu58-hdd
df -h
touch khanh.txt

#---- umount on node5, node8
umount /clu58-ssd
umount /clu58-hdd


# [V] 	Add shared storage to cluster resource. It's OK to set on a node5
pcs resource create clu58-ssd_res Filesystem \
device="/dev/clu58-ssd_vg/clu58-ssd_lv" directory="/clu58-ssd" fstype="gfs2" \
options="noatime,nodiratime" op monitor interval=10s on-fail=fence clone interleave=true


pcs resource create clu58-hdd_res Filesystem \
device="/dev/clu58-hdd_vg/clu58-hdd_lv" directory="/clu58-hdd" fstype="gfs2" \
options="noatime,nodiratime" op monitor interval=10s on-fail=fence clone interleave=true

pcs constraint order start clvmd-clone then clu58-ssd_res-clone
pcs constraint order start clvmd-clone then clu58-hdd_res-clone

pcs constraint colocation add clu58-ssd_res-clone with clvmd-clone
pcs constraint colocation add clu58-hdd_res-clone with clvmd-clone

pcs constraint show

# [VI] 	It's OK all. Make sure GFS2 filesystem is mounted on an active node and also make sure GFS2 mounts will move to another node if current active node will be down.
df -hT
echo "`hostname`...`date`" >> /clu58-ssd/tiktok.txt;cat /clu58-ssd/tiktok.txt
echo "`hostname`...`date`" >> /clu58-hdd/tiktok.txt;cat /clu58-hdd/tiktok.txt

##################################################### CLU37 ######################################################

# pacemaker - all node3, node7
yum -y install fence-agents-all lvm2-cluster gfs2-utils 

yum -y install pacemaker pcs
systemctl start pcsd
systemctl enable pcsd
passwd hacluster
ss -tupln | grep 2224

# run on node3
pcs cluster auth node3 node7
pcs cluster setup --name clu37 node3 node7
pcs cluster start --all
pcs cluster enable --all;
pcs status cluster;
pcs status corosync

ss -tupln | grep corosync

pcs resource providers
pcs resource agents ocf:heartbeat

# fence : https://redhatlinux.guru/2018/05/19/pacemaker-configure-hp-ilo-4-ssh-fencing/
fence_ilo5_ssh -a 10.38.16.157 -x -l admin -p h@yl4ch1nhb4n -o status
fence_ilo5_ssh -a 10.38.16.161 -x -l admin -p h@yl4ch1nhb4n -o status

pcs property set no-quorum-policy=freeze 
pcs stonith create node3-ilo5_fence fence_ilo5_ssh ipaddr="10.38.16.157" login="admin" secure="true" passwd=h@yl4ch1nhb4n  pcmk_host_list="node3" op monitor interval=60s
pcs stonith create node7-ilo5_fence fence_ilo5_ssh ipaddr="10.38.16.161" login="admin" secure="true" passwd=h@yl4ch1nhb4n  pcmk_host_list="node7" op monitor interval=60s
#check
corosync-quorumtool 
pcs property show
pcs status
pcs stonith show 

#[6] 	Add required resources. It's OK to set on a node.
https://www.unixarena.com/2016/01/rhel7-configuring-gfs2-on-pacemakercorosync-cluster.html/
https://www.golinuxcloud.com/configure-gfs2-setup-cluster-linux-rhel-centos-7/#Configure_DLM_Resource

# node3
lvmconf --enable-cluster;
grep locking_type /etc/lvm/lvm.conf | egrep -v '#'
#reboot
pcs property show
pcs resource create dlm ocf:pacemaker:controld op monitor interval=30s on-fail=fence clone interleave=true ordered=true;
pcs resource create clvmd ocf:heartbeat:clvm op monitor interval=30s on-fail=fence clone interleave=true ordered=true;
pcs constraint order start dlm-clone then clvmd-clone;
pcs constraint colocation add clvmd-clone with dlm-clone

# pv, vg, lv on node03
pvcreate /dev/mapper/clu37-ssd
pvdisplay
vgcreate -cy clu37-ssd_vg /dev/mapper/clu37-ssd
vgdisplay
lvcreate -l100%FREE -n clu37-ssd_lv clu37-ssd_vg
lvdisplay

pvcreate /dev/mapper/clu37-hdd
pvdisplay
vgcreate -cy clu37-hdd_vg /dev/mapper/clu37-hdd
vgdisplay
lvcreate -l100%FREE -n clu37-hdd_lv clu37-hdd_vg
lvdisplay

# --- mount to test--- on node3, node7 

vi /etc/fstab 
/dev/clu37-ssd_vg/clu37-ssd_lv /clu37-ssd gfs2 defaults 0 0 
/dev/clu37-hdd_vg/clu37-hdd_lv /clu37-hdd gfs2 defaults 0 0

--- mkfs ---
mkfs.gfs2 -p lock_dlm -t clu37:clu37-sdd -j 2 /dev/clu37-ssd_vg/clu37-ssd_lv
mkfs.gfs2 -p lock_dlm -t clu37:clu37-hdd -j 2 /dev/clu37-hdd_vg/clu37-hdd_lv

mkdir -p /clu37-ssd
mount /clu37-ssd
mkdir -p /clu37-hdd
mount /clu37-hdd
df -h
umount /clu37-ssd
umount /clu37-hdd


# [8] 	Add shared storage to cluster resource. It's OK to set on a node3

pcs resource create clu37-ssd_res Filesystem \
device="/dev/clu37-ssd_vg/clu37-ssd_lv" directory="/clu37-ssd" fstype="gfs2" \
options="noatime,nodiratime" op monitor interval=10s on-fail=fence clone interleave=true

pcs resource create clu37-hdd_res Filesystem \
device="/dev/clu37-hdd_vg/clu37-hdd_lv" directory="/clu37-hdd" fstype="gfs2" \
options="noatime,nodiratime" op monitor interval=10s on-fail=fence clone interleave=true

pcs constraint order start clvmd-clone then clu37-ssd_res-clone
pcs constraint order start clvmd-clone then clu37-hdd_res-clone

pcs constraint colocation add clu37-ssd_res-clone with clvmd-clone
pcs constraint colocation add clu37-hdd_res-clone with clvmd-clone

pcs constraint show

# [9] 	It's OK all. Make sure GFS2 filesystem is mounted on an active node and also make sure GFS2 mounts will move to another node if current active node will be down.
df -hT
echo "`hostname`...`date`" >> /clu37-ssd/tiktok.txt;cat /clu37-ssd/tiktok.txt
echo "`hostname`...`date`" >> /clu37-hdd/tiktok.txt;cat /clu37-hdd/tiktok.txt

########################################################################### END CLUSTER ##########################################################################################

### Clone 
# node 3
virt-clone --connect qemu:///system --original rt-app2	       --name rt-app2-prod	   --file /clu37-ssd/rt-app2-ssd.qcow2 --file /clu37-hdd/rt-app2-bk.qcow2
virt-clone --connect qemu:///system --original sim-prod	           --name sim-pro	       --file /clu37-ssd/sim.qcow2
virsh start rt-app2-prod	  														    
virsh start sim-pro	   

# node 5   
virt-clone --connect qemu:///system --original rt-app3	       --name rt-app3-prod	   --file /clu58-ssd/rt-app3-ssd.qcow2 --file /clu58-hdd/rt-app3-bk.qcow2
virt-clone --connect qemu:///system --original exploration	   --name exploration-prod --file /clu58-ssd/exploration-bk.qcow2 --file /clu58-ssd/exploration-ssd.qcow2
virt-clone --connect qemu:///system --original gui	           --name gui-prod	       --file /clu58-ssd/gui-ssd.qcow2 --file /clu58-hdd/gui-bk-1.qcow2
virsh start rt-app3-prod	  
virsh start exploration-prod
virsh start gui-prod	      