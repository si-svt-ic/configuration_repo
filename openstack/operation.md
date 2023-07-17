#
##
### VM

Config allow ssh 

Centos 7

    sed -i s/^PasswordAuthentication.*$/"PasswordAuthentication yes"/ /etc/ssh/sshd_config; sed -i '38 i PermitRootLogin yes' /etc/ssh/sshd_config; systemctl restart sshd

Centos 6    

    sed -i s/^PasswordAuthentication.*$/"PasswordAuthentication yes"/ /etc/ssh/sshd_config; sed -i '38 i PermitRootLogin yes' /etc/ssh/sshd_config; /etc/init.d/sshd restart