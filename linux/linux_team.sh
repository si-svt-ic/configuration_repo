
------ team0 ( eno1+eno2) -----------------------

vi /etc/sysconfig/network-scripts/ifcfg-eno1
TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=none
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
#NM_CONTROLLED=no
NAME=eno1
DEVICE=eno1
ONBOOT=yes
DEVICETYPE=TeamPort
TEAM_MASTER=team0
TEAM_PORT_CONFIG='{"prio":9}'

vi /etc/sysconfig/network-scripts/ifcfg-eno2
TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=none
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
#NM_CONTROLLED=no
NAME=eno2
DEVICE=eno2
ONBOOT=yes
DEVICETYPE=TeamPort
TEAM_MASTER=team0
TEAM_PORT_CONFIG='{"prio":10}'

vi /etc/sysconfig/network-scripts/ifcfg-team0 
DEVICE=team0  
PROXY_METHOD=none  
BROWSER_ONLY=no  
BOOTPROTO=none  
#NM_CONTROLLED=no
IPADDR=10.38.22.18
PREFIX=25  
GATEWAY=10.38.22.1
DEFROUTE=yes  
IPV4_FAILURE_FATAL=no  
IPV6INIT=yes  
NAME=team0  
ONBOOT=yes  
DEVICETYPE=Team  
TEAM_CONFIG="{\"runner\": {\"name\": \"lacp\", \"active\": true, \"fast_rate\": true, \"tx_hash\": [\"eth\", \"ipv4\", \"ipv6\"]},\"link_watch\":    {\"name\": \"ethtool\"}}"  

service network restart

teamdctl team0 state

-------- team1 ( eno49 + eno50 ) ---------------------------
vi /etc/sysconfig/network-scripts/ifcfg-eno49
TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=none
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
#NM_CONTROLLED=no
NAME=eno49
DEVICE=eno49
ONBOOT=yes
DEVICETYPE=TeamPort
TEAM_MASTER=team1
TEAM_PORT_CONFIG='{"prio":9}'

vi /etc/sysconfig/network-scripts/ifcfg-eno50
TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=none
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
#NM_CONTROLLED=no
NAME=eno50
DEVICE=eno50
ONBOOT=yes
DEVICETYPE=TeamPort
TEAM_MASTER=team1
TEAM_PORT_CONFIG='{"prio":10}'

vi /etc/sysconfig/network-scripts/ifcfg-team1 
DEVICE=team1
PROXY_METHOD=none  
BROWSER_ONLY=no  
BOOTPROTO=none 
#NM_CONTROLLED=no
DEFROUTE=yes  
IPV4_FAILURE_FATAL=no  
IPV6INIT=yes  
NAME=team1
ONBOOT=yes  
DEVICETYPE=Team  
TEAM_CONFIG="{\"runner\": {\"name\": \"lacp\", \"active\": true, \"fast_rate\": true, \"tx_hash\": [\"eth\", \"ipv4\", \"ipv6\"]},\"link_watch\":    {\"name\": \"ethtool\"}}"  

 service network restart
 teamdctl team1 state

--------------team2 ( ens1f0+ens1f1 ) ----------------------------
vi /etc/sysconfig/network-scripts/ifcfg-ens1f0
TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=none
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
#NM_CONTROLLED=no
NAME=ens1f0
DEVICE=ens1f0
ONBOOT=yes
DEVICETYPE=TeamPort
TEAM_MASTER=team2
TEAM_PORT_CONFIG='{"prio":9}'

vi /etc/sysconfig/network-scripts/ifcfg-ens1f1
TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=none
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
#NM_CONTROLLED=no
NAME=ens1f1
DEVICE=ens1f1
ONBOOT=yes
DEVICETYPE=TeamPort
TEAM_MASTER=team2
TEAM_PORT_CONFIG='{"prio":10}'

vi /etc/sysconfig/network-scripts/ifcfg-team2
DEVICE=team2
PROXY_METHOD=none  
BROWSER_ONLY=no  
BOOTPROTO=none 
#NM_CONTROLLED=no
DEFROUTE=yes  
IPV4_FAILURE_FATAL=no  
IPV6INIT=yes  
NAME=team2
ONBOOT=yes  
DEVICETYPE=Team  
TEAM_CONFIG="{\"runner\": {\"name\": \"lacp\", \"active\": true, \"fast_rate\": true, \"tx_hash\": [\"eth\", \"ipv4\", \"ipv6\"]},\"link_watch\":    {\"name\": \"ethtool\"}}"  

 service network restart
 teamdctl team1 state
