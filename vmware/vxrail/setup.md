Default user

    Component	Networking Configuration	Username	Default Password
    BIOS	N/A	N/A	emcbios
    iDRAC	DHCP	root	calvin
    ESXi root	DHCP	root	Passw0rd!
    vCenter Server Appliance	Defined at deployment	root	vmware
    Platform Services Controller	Defined at deployment	root	vmware
    vRealize Log Insight	DHCP	root	Passw0rd!
    VxRail Manager	192.168.10.200	root	Passw0rd!
    VxRail Manager Plugin	Defined at deployment	root	Passw0rd!

VxRail Manager	 	
    mystic	
    VxRailManager@201602!

VxRail Manager Plugin	 	
    mystic	
    VBManager201415!


"vxrail-primary --destroy"

- reboot all esxi hosts you planning to use

- setup vxrail manager again via command "#vxrail-primary --setup"

[root@node-78750:~] vxrail-primary --stop
Try to power off VxRail Manager...
PRIMARY: 2023-07-12 16:27:27,612.612Z - INFO VxRail Manager has been powered off
VxRail Manager has been powered off
[root@node-78750:~] vxrail-primary --config --vxrail-address 10.21.46.73 --vxrail-netmask 255.255.255.0 --vxrail-gateway 10.21.46.254 --vlan 46
PRIMARY: 2023-07-12 16:31:15,796.796Z - INFO Configing Manager with IP 10.21.46.73/255.255.255.0 gateway 10.21.46.254
Try to power on VxRail Manager ...

Restart loudmouth on the VxRail Manager vm:

    cd /opt/vmware/share/vami/
    ./vami_set_network eth0 STATICV4 10.21.46.73 255.255.255.0 10.21.46.254

    systemctl restart vmware-loudmouth
    /usr/lib/vmware-loudmouth/bin/loudmouthc query

    tail -f /var/log/microservice_log/dayone.log

ESxi host
    
    /usr/lib/vmware/loudmouth/bin/loudmouthc query
    /etc/init.d/loudmouth restart