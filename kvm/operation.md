# Change password of cloud image 

    openssl passwd -1 admin123
    $1$vhevIv7o$M801z0RZUldlcUcuoFGvo.

    yum install libvirtd libguestfs libguestfs-tools
    guestfish -w -a CentOS-7-x86_64-GenericCloud-2009.qcow2
    ><fs> run
    ><fs> mount /dev/sda
    /dev/sda   /dev/sda1  
    ><fs> mount /dev/sda1 /
    ><fs> vi /etc/shadow
    root:$1$vhevIv7o$M801z0RZUldlcUcuoFGvo.:18565:0:99999:7:::
    