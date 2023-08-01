[root@controller ~]# mysql_secure_installation

NOTE: RUNNING ALL PARTS OF THIS SCRIPT IS RECOMMENDED FOR ALL MariaDB
      SERVERS IN PRODUCTION USE!  PLEASE READ EACH STEP CAREFULLY!

In order to log into MariaDB to secure it, we'll need the current
password for the root user.  If you've just installed MariaDB, and
you haven't set the root password yet, the password will be blank,
so you should just press enter here.

Enter current password for root (enter for none): 
OK, successfully used password, moving on...

Setting the root password ensures that nobody can log into the MariaDB
root user without the proper authorisation.

You already have a root password set, so you can safely answer 'n'.

Change the root password? [Y/n] n
 ... skipping.

By default, a MariaDB installation has an anonymous user, allowing anyone
to log into MariaDB without having to have a user account created for
them.  This is intended only for testing, and to make the installation
go a bit smoother.  You should remove them before moving into a
production environment.

Remove anonymous users? [Y/n] 
 ... Success!

Normally, root should only be allowed to connect from 'localhost'.  This
ensures that someone cannot guess at the root password from the network.

Disallow root login remotely? [Y/n] n
 ... skipping.

By default, MariaDB comes with a database named 'test' that anyone can
access.  This is also intended only for testing, and should be removed
before moving into a production environment.

Remove test database and access to it? [Y/n] 
 - Dropping test database...
 ... Success!
 - Removing privileges on test database...
 ... Success!

Reloading the privilege tables will ensure that all changes made so far
will take effect immediately.

Reload privilege tables now? [Y/n] 
 ... Success!

Cleaning up...

All done!  If you've completed all of the above steps, your MariaDB
installation should now be secure.

Thanks for using MariaDB!





# Privileges
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%'IDENTIFIED BY 'Admin@123' WITH GRANT OPTION;
FLUSH PRIVILEGES;  

[root@control3 ~]# mysql -u root -p
Enter password: 
ERROR 1045 (28000): Access denied for user 'root'@'localhost' (using password: YES)

mysqld_safe --skip-grant-tables &
mysql -u root -p
Enter password: <No password>

MariaDB [(none)]> GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'Admin@123';
ERROR 1290 (HY000): The MariaDB server is running with the --skip-grant-tables option so it cannot execute this statement
MariaDB [(none)]> FLUSH PRIVILEGES;
Query OK, 0 rows affected (0.015 sec)

MariaDB [(none)]> GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'Admin@123';
Query OK, 0 rows affected (0.011 sec)



MariaDB [(none)]> GRANT ALL PRIVILEGES ON *.* TO 'root'@'%'IDENTIFIED BY 'admin123' WITH GRANT OPTION;
ERROR 1045 (28000): Access denied for user 'root'@'%' (using password: YES)

mysql_secure_installation
Change the root password? [Y/n] n

Reloading the privilege tables will ensure that all changes made so far
will take effect immediately.

Reload privilege tables now? [Y/n] 
MariaDB [(none)]> SHOW GRANTS FOR 'root'@'%';
+--------------------------------------------------------------------------------------------------------------------------------+
| Grants for root@%                                                                                                              |
+--------------------------------------------------------------------------------------------------------------------------------+
| GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY PASSWORD '*7BB96B4D3E986612D96E53E62DBE9A38AAA40A5A' WITH GRANT OPTION |
+--------------------------------------------------------------------------------------------------------------------------------+


[root@controller ~]# ss -tulpn |grep mysql
tcp    LISTEN     0      128       *:3306                  *:*                   users:(("mysqld",pid=1283,fd=19))

[root@controller ~]# mysql -u root -p
show database;
use cinder;
show tables;


root@OSControllerNode:/etc/rabbitmq# mysql 
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 40
Server version: 10.0.34-MariaDB-0ubuntu0.16.04.1 Ubuntu 16.04

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

> select user();




GRANT ALL PRIVILEGES ON database.table TO 'user'@'localhost';




MariaDB [(none)]> create database keystone;
Query OK, 1 row affected (0.00 sec)

MariaDB [(none)]> GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY 'k3yst0ne';
Query OK, 0 rows affected (0.00 sec)

MariaDB [(none)]> GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY 'k3yst0ne';
Query OK, 0 rows affected (0.00 sec)


MariaDB [(none)]> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| keystone           |
| mysql              |
| performance_schema |
+--------------------+
4 rows in set (0.00 sec)


GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'dbr00tpassword';


7down voteaccepted	Since you say that this is a devstack installation, I'm assuming that you aren't running this in a production environment. Openstack allows users to bump up their over-subscription ratio for the RAM. By default, it is kept at 1.5 times the physical RAM available in the machine. Hence, it should be 12 Gb of usable memory. To change the subscription ratio:
	sudo vim /etc/nova/nova.conf
#Add these two lines
ram_allocation_ratio=2
cpu_allocation_ratio=20 # Default value here is 16
	These values are just a rough estimate. Change the values around to make them work for your environment. Restart the Devstack.
	To check if the changes were made, log into mysql (or whichever DB is supporting devstack) and check:
	#mysql
	mysql> use nova;
mysql> select * from compute_nodes \G;
*************************** 1. row ***************************
      created_at: 2015-09-25 13:52:55
      updated_at: 2016-02-03 18:32:49
      deleted_at: NULL
              id: 1
      service_id: 7
           vcpus: 8
       memory_mb: 12007
        local_gb: 446
      vcpus_used: 6
  memory_mb_used: 8832
   local_gb_used: 80
 hypervisor_type: QEMU
    disk_available_least: 240
     free_ram_mb: 3175
    free_disk_gb: 366
    current_workload: 0
     running_vms: 4
       pci_stats: NULL
         metrics: []
.....
1 row in set (0.00 sec)
	The Scheduler looks at the free_ram_mb. If you have a free_ram_mb of 3175 and if you want to run a new m1.medium instance with 4096M of memory, the Scheduler will end up with this message in the logs:

From <https://stackoverflow.com/questions/35184879/openstack-devstack-cant-create-instance-there-are-not-enough-hosts-available> 


root@OSControllerNode:/etc/mysql/mariadb.conf.d# mysql -u root -p
Enter password: 
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 43
Server version: 10.0.34-MariaDB-0ubuntu0.16.04.1 Ubuntu 16.04

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> show variables like 'char%'; show variables like 'collation%';
+--------------------------+----------------------------+
| Variable_name            | Value                      |
+--------------------------+----------------------------+
| character_set_client     | utf8mb4                    |
| character_set_connection | utf8mb4                    |
| character_set_database   | utf8mb4                    |
| character_set_filesystem | binary                     |
| character_set_results    | utf8mb4                    |
| character_set_server     | utf8mb4                    |
| character_set_system     | utf8                       |
| character_sets_dir       | /usr/share/mysql/charsets/ |
+--------------------------+----------------------------+
8 rows in set (0.00 sec)

+----------------------+--------------------+
| Variable_name        | Value              |
+----------------------+--------------------+
| collation_connection | utf8mb4_general_ci |
| collation_database   | utf8mb4_general_ci |
| collation_server     | utf8mb4_general_ci |
+----------------------+--------------------+
3 rows in set (0.00 sec)



Edit the /etc/mysql/my.cnf file. Under the [mysqld] header, you will find the bind-address keyword pointing to localhost. Set this to the IP address of the controller node.
Also, add the following lines shown just below the bind-address in order to enable UTF-8 encoding:
Copy
[mysqld]
bind-address = 172.22.6.95
default-storage-engine = innodb
collation-server = utf8_general_ci
init-connect = 'SET NAMES utf8'
character-set-server = utf8
Once this is done, restart the database service with the following command:

From <https://www.packtpub.com/mapt/book/virtualization_and_cloud/9781787123182/2/ch02lvl1sec15/installing-common-components> 



MariaDB [(none)]>  show variables like 'char%'; show variables like 'collation%';
+--------------------------+----------------------------+
| Variable_name            | Value                      |
+--------------------------+----------------------------+
| character_set_client     | utf8mb4                    |
| character_set_connection | utf8mb4                    |
| character_set_database   | utf8                       |
| character_set_filesystem | binary                     |
| character_set_results    | utf8mb4                    |
| character_set_server     | utf8                       |
| character_set_system     | utf8                       |
| character_sets_dir       | /usr/share/mysql/charsets/ |
+--------------------------+----------------------------+
8 rows in set (0.00 sec)

+----------------------+--------------------+
| Variable_name        | Value              |
+----------------------+--------------------+
| collation_connection | utf8mb4_general_ci |
| collation_database   | utf8_general_ci    |
| collation_server     | utf8_general_ci    |
+----------------------+--------------------+
3 rows in set (0.00 sec)


