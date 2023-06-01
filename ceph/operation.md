## Operation

### 
    Volume on Openstack Dashboard:        8d38d7e3-dd93-4942-a304-9b8971176ae0
    Image on Ceph Pool           : volume-8d38d7e3-dd93-4942-a304-9b8971176ae0

### clean images with snapshot

    rbd ls volumes
    [root@ceph01 ~]# rbd disk-usage --pool volumes volume-4f482f3d-037d-4d5a-836f-2c9a321a710d
    NAME                                                                                                   PROVISIONED USED    
    volume-4f482f3d-037d-4d5a-836f-2c9a321a710d@volume-4f482f3d-037d-4d5a-836f-2c9a321a710d2021-05-19.snap      50 GiB 832 MiB 
    volume-4f482f3d-037d-4d5a-836f-2c9a321a710d                                                                 50 GiB     0 B 
    <TOTAL>                                                                                                     50 GiB 832 MiB 
    [root@ceph01 ~]# rbd --pool rbd snap purge test^C
    [root@ceph01 ~]#  rbd --pool volumes snap purge volumes/volume-4f482f3d-037d-4d5a-836f-2c9a321a710d
    Removing all snapshots: 100% complete...done.
    [root@ceph01 ~]# 

