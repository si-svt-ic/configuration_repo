# Name: Quy trinh migrate MBF - KMV to OS
# Duration: 1h30-2h
# Create: 10-2-2020
# Action: 2-2020

# Môi trường 

[root@controller01 ~(keystone)]# openstack network list
+--------------------------------------+----------------+--------------------------------------+
| ID                                   | Name           | Subnets                              |
+--------------------------------------+----------------+--------------------------------------+
| 28302b07-83a1-4732-9a67-a4a195e644c2 | provider-dmz   | 6ec3760d-7649-423a-85cb-d46073e516d2 |
| 79d9d67c-13d5-4617-b8e7-b8c1034183f3 | provider-local | 0456cb58-ff2e-4c6e-b377-603aee0bef93 |
+--------------------------------------+----------------+--------------------------------------+
# node7 
ae_mssp-prod   				/vm_node7/ae_mssp-prod.qcow2    
me_mssp-prod   				/vm_node7/me_mssp-prod.qcow2    
mshop_web-prod   			/vm_node7/mshop_web-prod.qcow2  
mshop_app-prod   			/vm_node7/mshop_app-prod.qcow2  
db_mssp_bk-prod  			/vm_node7/db_mssp_bk-prod.qcow2 

# node8                     
pmbh-prod           		/vm_node8/pmbh-prod.qcow2        
home_mssp-prod              /vm_node8/home_mssp-prod.qcow2  
db_mssp-prod                /vm_node8/db_mssp-prod.qcow2    


# Shutdown các VM 
# node7 104 GB
scp /vm_node7/ae_mssp-prod.qcow2           node7:/vg_vps/images/migration/ae_mssp-prod.qcow2
scp /vm_node7/me_mssp-prod.qcow2           node7:/vg_vps/images/migration/me_mssp-prod.qcow2
scp /vm_node7/mshop_web-prod.qcow2         node7:/vg_vps/images/migration/mshop_web-prod.qcow2
scp /vm_node7/mshop_app-prod.qcow2         node7:/vg_vps/images/migration/mshop_app-prod.qcow2
scp /vm_node7/db_mssp_bk-prod.qcow2        node7:/vg_vps/images/migration/db_mssp_bk-prod.qcow2

# node8 162 GB
scp /vm_node8/pmbh-prod.qcow2              node7:/vg_vps/images/migration/pmbh-prod.qcow2          
scp /vm_node8/home_mssp-prod.qcow2         node7:/vg_vps/images/migration/home_mssp-prod.qcow2
scp /vm_node8/db_mssp-prod.qcow2           node7:/vg_vps/images/migration/db_mssp-prod.qcow2

# Thời gian dự kiến 1h30

# Thời gian Copy = Dung lượng VM/ Tốc độ đường truyền ( Node7 -> Node7, Node7 -> Node8 )
266GB / 1 GB/s = 260s = 5 phut
# Thời gian Import ( Node8 -> Glance -> NFS )
5 phut * 8 = 40 phút
# Thời gian Create VM ( NFS -> Glance -> Cinder -> Ceph )
~ 40 phút 

# import into glance 

openstack image create ae_mssp-prod    --disk-format qcow2 --container-format bare --public --file /vg_vps/images/migration/ae_mssp-prod.qcow2      
openstack image create me_mssp-prod    --disk-format qcow2 --container-format bare --public --file /vg_vps/images/migration/me_mssp-prod.qcow2
openstack image create mshop_web-prod  --disk-format qcow2 --container-format bare --public --file /vg_vps/images/migration/mshop_web-prod.qcow2
openstack image create mshop_app-prod  --disk-format qcow2 --container-format bare --public --file /vg_vps/images/migration/mshop_app-prod.qcow2
openstack image create db_mssp_bk-prod --disk-format qcow2 --container-format bare --public --file /vg_vps/images/migration/db_mssp_bk-prod.qcow2
openstack image create pmbh-prod       --disk-format qcow2 --container-format bare --public --file /vg_vps/images/migration/pmbh-prod.qcow2          
openstack image create home_mssp-prod  --disk-format qcow2 --container-format bare --public --file /vg_vps/images/migration/home_mssp-prod.qcow2
openstack image create db_mssp-prod    --disk-format qcow2 --container-format bare --public --file /vg_vps/images/migration/db_mssp-prod.qcow2
 
# create server 

openstack server create --flavor goi3 --image ae_mssp-prod   	--nic net-id=28302b07-83a1-4732-9a67-a4a195e644c2,v4-fixed-ip=10.38.2.3     ae_mssp-prod   
openstack server create --flavor goi1 --image me_mssp-prod   	--nic net-id=79d9d67c-13d5-4617-b8e7-b8c1034183f3,v4-fixed-ip=10.38.22.70   me_mssp-prod   
openstack server create --flavor goi3 --image mshop_web-prod    --nic net-id=28302b07-83a1-4732-9a67-a4a195e644c2,v4-fixed-ip=10.38.2.6   mshop_web-prod 
openstack server create --flavor goi3 --image mshop_app-prod    --nic net-id=79d9d67c-13d5-4617-b8e7-b8c1034183f3,v4-fixed-ip=10.38.22.76   mshop_app-prod 
openstack server create --flavor goi1 --image db_mssp_bk-prod   --nic net-id=79d9d67c-13d5-4617-b8e7-b8c1034183f3,v4-fixed-ip=10.38.22.74   db_mssp_bk-prod
openstack server create --flavor goi1 --image pmbh-prod         --nic net-id=79d9d67c-13d5-4617-b8e7-b8c1034183f3,v4-fixed-ip=10.38.22.73   pmbh-prod      
openstack server create --flavor goi3 --image home_mssp-prod    --nic net-id=79d9d67c-13d5-4617-b8e7-b8c1034183f3,v4-fixed-ip=10.38.22.71   home_mssp-prod 
openstack server create --flavor goi3 --image db_mssp-prod      --nic net-id=79d9d67c-13d5-4617-b8e7-b8c1034183f3,v4-fixed-ip=10.38.22.72   db_mssp-prod   

# Thủ tục test nếu cần
<MBF thực hiện>

# Thủ tục rollback nếu có lỗi
Start lại VM ở node7,8

