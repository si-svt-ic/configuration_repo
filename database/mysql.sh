

root@OSControllerNode:/etc/mysql/mariadb.conf.d# ss  -ln | grep 3306
tcp    LISTEN     0      128    172.22.6.95:3306     

MariaDB [cinder]> update volumes set deleted=true;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%'IDENTIFIED BY 's4ngt4oh0ch01' WITH GRANT OPTION; 
FLUSH PRIVILEGES;

MariaDB [heat]> update stack set action='DELETE' where action='delete';      
Query OK, 3 rows affected (0.004 sec)
Rows matched: 15  Changed: 3  Warnings: 0








# delete from cinder.volume_attachment where id = 'e50bba9d-2b52-49ed-bcbd-00f4f690dab6';
# select  * from cinder.volume_attachment where id = 'f776071a-b124-4094-ba6b-29a467aa6400';

# delete volume 
UPDATE cinder.volumes
SET created_at='2021-06-03 03:38:15.000', updated_at='2021-06-03 03:43:07.000', deleted_at=NULL, deleted=1, ec2_id=NULL, user_id='33ad37900efa44109928e97d64952451', project_id='c5403d0a534c4e5c9fcda903c8642b31', host='controller01@IBMSSD1#ssd1', `size`=12, availability_zone='nova', status='deleted', attach_status='detached', scheduled_at='2021-06-03 03:38:15.000', launched_at=NULL, terminated_at='2021-06-03 03:43:07.000', display_name='test', display_description='', provider_location=NULL, provider_auth=NULL, snapshot_id=NULL, volume_type_id='5a5137e1-8de6-47fd-9e2c-7750378aa046', source_volid=NULL, bootable=0, provider_geometry=NULL, `_name_id`=NULL, encryption_key_id=NULL, migration_status=NULL, replication_status='not-capable', replication_extended_status=NULL, replication_driver_data=NULL, consistencygroup_id=NULL, provider_id=NULL, multiattach=0, previous_status=NULL, cluster_name=NULL, group_id=NULL, service_uuid=NULL, shared_targets=1
WHERE id='84a8b3b1-04c2-4d42-b4b5-5043fc466462';

#select  * from cinder.volumes
#select  * from cinder.volumes where id in( 'f776071a-b124-4094-ba6b-29a467aa6400', 'e50bba9d-2b52-49ed-bcbd-00f4f690dab6');
#update cinder.volumes set display_description = '' where id = 'e50bba9d-2b52-49ed-bcbd-00f4f690dab6';
update cinder.volumes set attach_status = 'detached' where id = 'e50bba9d-2b52-49ed-bcbd-00f4f690dab6';
#update cinder.volumes set attach_status = 'detached' where id = 'f776071a-b124-4094-ba6b-29a467aa6400';


#select  * from cinder.volume_attachment ;

update cinder.volume_attachment set attach_status = 'detached', attached_host = null , instance_uuid = null, mountpoint =null, connection_info =null, connector = null where volume_id = 'e50bba9d-2b52-49ed-bcbd-00f4f690dab6';
update cinder.volume_attachment set attach_status = 'detached', attached_host = null , instance_uuid = null, mountpoint =null, connection_info =null, connector = null where volume_id = 'f776071a-b124-4094-ba6b-29a467aa6400';
#update cinder.volume_attachment set attach_status = 'detached' where volume_id = 'f776071a-b124-4094-ba6b-29a467aa6400';
select  * from cinder.volume_attachment where volume_id in( 'f776071a-b124-4094-ba6b-29a467aa6400', 'e50bba9d-2b52-49ed-bcbd-00f4f690dab6');



cinder reset-state --state available e50bba9d-2b52-49ed-bcbd-00f4f690dab6
cinder reset-state --state available f776071a-b124-4094-ba6b-29a467aa6400


#
select DATE_FORMAT (n.created_at, '%Y/%m/%d') as created_at ,n.display_name, n.uuid, memory_mb, vcpus, i.ip_address, cva.volume_id, c.bootable, c.size, pn.name, n.host
from nova.instances n, neutron.ipallocations i, neutron.ports p, cinder.volume_attachment cva, cinder.volumes c, keystone.project pn
where
n.display_name not like '%Test%'
and n.deleted = 0
and n.project_id = pn.id
and n.uuid = p.device_id
and p.id = i.port_id
and cva.volume_id= c.id
and cva.deleted = 0
and n.uuid= cva.instance_uuid;


select v.display_name,m.volume_id ,m.`key` ,m.value from cinder.volumes v join cinder.volume_metadata m on v.id = m.volume_id WHERE m.`key` = "ldev" and v.deleted = 0 and v.host LIKE '%hbsd%'

grant all privileges on *.* to 'cinder'@'%' identified by password 'e14c5e153c394117' with grant option; 


=================================================== MariaDB  ==============================================================

MariaDB [cinder]> 
delete from `volumes` where display_name = "ceph_inst2_vol1"; 
delete from `instances` where uuid = "9f6eafed-09d0-43e1-8d78-342ae1585b4c"; 
delete from block_device_mapping where instance_uuid='9f6eafed-09d0-43e1-8d78-342ae1585b4c'


# delete from cinder.volume_attachment where id = 'e50bba9d-2b52-49ed-bcbd-00f4f690dab6';
# select  * from cinder.volume_attachment where id = 'f776071a-b124-4094-ba6b-29a467aa6400';


#select  * from cinder.volumes
#select  * from cinder.volumes where id in( 'f776071a-b124-4094-ba6b-29a467aa6400', 'e50bba9d-2b52-49ed-bcbd-00f4f690dab6');
#update cinder.volumes set display_description = '' where id = 'e50bba9d-2b52-49ed-bcbd-00f4f690dab6';
update cinder.volumes set attach_status = 'detached' where id = 'e50bba9d-2b52-49ed-bcbd-00f4f690dab6';
#update cinder.volumes set attach_status = 'detached' where id = 'f776071a-b124-4094-ba6b-29a467aa6400';


#select  * from cinder.volume_attachment ;

update cinder.volume_attachment set attach_status = 'detached', attached_host = null , instance_uuid = null, mountpoint =null, connection_info =null, connector = null where volume_id = 'e50bba9d-2b52-49ed-bcbd-00f4f690dab6';
update cinder.volume_attachment set attach_status = 'detached', attached_host = null , instance_uuid = null, mountpoint =null, connection_info =null, connector = null where volume_id = 'f776071a-b124-4094-ba6b-29a467aa6400';
#update cinder.volume_attachment set attach_status = 'detached' where volume_id = 'f776071a-b124-4094-ba6b-29a467aa6400';
select  * from cinder.volume_attachment where volume_id in( 'f776071a-b124-4094-ba6b-29a467aa6400', 'e50bba9d-2b52-49ed-bcbd-00f4f690dab6');



cinder reset-state --state available e50bba9d-2b52-49ed-bcbd-00f4f690dab6
cinder reset-state --state available f776071a-b124-4094-ba6b-29a467aa6400