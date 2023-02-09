# root xfs rhel8
In vmware environment, we create a Tepmlate with root sda = 10G. 
However we may edit size of the sda = 30G. We need to resize in VM guest OS rhel8. 


parted /dev/sda
 Number  Start   End     Size    File system  Name                  Flags
 1      1049kB  630MB   629MB   fat32        EFI System Partition  boot, esp
 2      630MB   1704MB  1074MB  xfs
 3      1704MB  90.0GB  88.3GB                                     lvm

(parted) 3                                                                
(parted) resizepart 3 100%                                                
(parted) p                                                                
Model: VMware Virtual disk (scsi)
Disk /dev/sda: 107GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags: 

Number  Start   End     Size    File system  Name                  Flags
 1      1049kB  630MB   629MB   fat32        EFI System Partition  boot, esp
 2      630MB   1704MB  1074MB  xfs
 3      1704MB  107GB   106GB             
 
pvresize /dev/sda3
lvextend -l +100%FREE /dev/mapper/rhel-root


xfs_growfs /dev/mapper/rhel-root


# root xfs centos7

(virtualenv) [root@opsaio85 /]# lvextend /dev/mapper/centos-root -L +200G
  Size of logical volume centos/root changed from 50.00 GiB (12800 extents) to 250.00 GiB (64000 extents).
  Logical volume centos/root successfully resized.

 xfs_growfs /dev/mapper/centos-root 

