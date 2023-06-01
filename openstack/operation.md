#
##
### VM
Create VM

    openstack server create --flavor 0dbc6b60-bab1-4e70-851d-b22cc572dc90  --boot-from-volume 100 --image CentOS7.9  --nic net-id=28302b07-83a1-4732-9a67-a4a195e644c2,v4-fixed-ip=10.38.2.28 --security-group 0c5349f8-4342-4289-a954-830cea274a26 vnlink-vps4-01

Config allow ssh 

Centos 7

    sed -i s/^PasswordAuthentication.*$/"PasswordAuthentication yes"/ /etc/ssh/sshd_config; sed -i '38 i PermitRootLogin yes' /etc/ssh/sshd_config; systemctl restart sshd

Centos 6    

    sed -i s/^PasswordAuthentication.*$/"PasswordAuthentication yes"/ /etc/ssh/sshd_config; sed -i '38 i PermitRootLogin yes' /etc/ssh/sshd_config; /etc/init.d/sshd restart

##

#

openstack network create --share --provider-physical-network datacentre --external --provider-network-type flat provider-ens192

openstack subnet create --subnet-range 192.168.24.0/24 --gateway 192.168.24.1 \
--network  provider-ens192 --allocation-pool start=192.168.24.80,end=192.168.24.90 \
--dns-nameserver 8.8.8.8 provider-ens192-subnet