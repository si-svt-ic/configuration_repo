

##### 4.2. CONFIGURING A LOCAL REPOSITORY FOR OFFLINE RED HAT VIRTUALIZATION MANAGER INSTALLATION  #############
subscription-manager list --available

Subscription Name:   Red Hat Enterprise Linux, Self-Support (128 Sockets, NFR, Partner Only)
Pool ID:             8a85f99a65c8c8a10166beafed2b43e9

Subscription Name:   Red Hat Enterprise Linux, Self-Support (128 Sockets, NFR, Partner Only)
Pool ID:             8a85f98d66f82db60166f88af3ac0ed7


subscription-manager attach --pool=8a85f98d66f82db60166f88af3ac0ed7
subscription-manager repos --disable=*

subscription-manager repos --enable=rhel-7-server-rpms
subscription-manager repos --enable=rhel-7-server-supplementary-rpms
# subscription-manager repos --enable=rhel-7-server-rhv-4.0-rpms
# subscription-manager repos --enable=jb-eap-7.0-for-rhel-7-server-rpms

yum install vsftpd

systemctl start vsftpd.service
systemctl enable vsftpd.service

mkdir /var/ftp/pub/rhevrepo
reposync -l -p /var/ftp/pub/rhevrepo

yum install createrepo
for DIR in `find /var/ftp/pub/rhevrepo -maxdepth 1 -mindepth 1 -type d`; do createrepo $DIR; done;


[root@kvm_node3 ~]# setenforce 0
[root@kvm_node3 ~]# iptables -F                                                                   // chủ yếu do firewall

######### On offline client server ###################

vi /etc/yum.repos.d/local.repo

[local]
name=local
baseurl=ftp://10.1.29.40/pub/rhevrepo/rhel-7-server-rpms                                 // sử dùng ftp mặc định thư mục đến là /var/ftp/ nên chỉ cần trỏ baseurl từ pub/rhevrepo/ten_repo
enable=1
gpgcheck=0

yum clean all
yum repolist

---------------------------Repo local and share with offline server  -------------------------------------------

####################### cach 1 : mount cdrom ##############################################################

mount /dev/sr0	/media/                                  thường ổ iso sẽ mount vào /dev/sr0 
cd /etc/yum.repos.d/
rm -f * 
vi local.repo
---add---
[REPO]
name=local.repo
baseurl=file:///media
enabled=1
gpgcheck=0

yum clean all
yum list available


################## cach 2 : reposync ##########################################################################

### On repo server ###

mkdir -p /var/www/html/repo                                                             // tạo thư mục chứa repo
yum repolist                                                                            // kiểm tra tên repo muốn load về hoặc search online 
reposync -l -r  rhel-7-server-rpms -p /var/www/http/repo --download-metadata --downloadedcomps						// đồng bộ gói tên là rhel-7-server-rpms về thư mục -p với 2 option là kèm thông tin
createrepo -v /var/ftp/pub/rhevrepo/rhel-7-server-rpms/ -g comps.xml                                        // -g là group 

### share ###
yum install vsftpd

systemctl start vsftpd.service
systemctl enable vsftpd.service

[root@kvm_node3 ~]# setenforce 0
[root@kvm_node3 ~]# iptables -F


######### On offline client server ###################

vi /etc/yum.repos.d/local.repo

[local]
name=local
baseurl=ftp://10.1.29.40/pub/rhevrepo/rhel-7-server-rpms                                 // sử dùng ftp mặc định thư mục đến là /var/ftp/ nên chỉ cần trỏ baseurl từ pub/rhevrepo/ten_repo
enable=1
gpgcheck=0

yum clean all
yum repolist






























































