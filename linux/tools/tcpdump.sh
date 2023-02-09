
@ HTTP GET
https://www.middlewareinventory.com/blog/tcpdump-capture-http-get-post-requests-apache-weblogic-websphere/
tcpdump -i ens192 -s 0 -A 'tcp dst port 8080 or tcp dst port 443 and tcp[((tcp[12:1] & 0xf0) >> 2):4] = 0x47455420 or tcp[((tcp[12:1] & 0xf0) >> 2):4] = 0x504F5354' and host 10.1.21.50
tcpdump -i ens192 -s 0 -A 'tcp[((tcp[12:1] & 0xf0) >> 2):4] = 0x47455420'
tcpdump -i ens192 -s 0 -A 'tcp dst port 8080 and tcp[((tcp[12:1] & 0xf0) >> 2):4] = 0x47455420'


@@ Kiem tra tu 1 port server traffic tu 1 client ( bo qua SSH )

[root@host01 ~]# tcpdump -i eno1 -n src host 10.3.0.23 and not dst port 22 and not src port 22 
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eno1, link-type EN10MB (Ethernet), capture size 65535 bytes
10:51:40.882764 IP 10.3.0.23 > 10.1.17.11: ICMP echo request, id 1, seq 1061, length 40
10:51:41.894614 IP 10.3.0.23 > 10.1.17.11: ICMP echo request, id 1, seq 1062, length 40
10:51:42.903551 IP 10.3.0.23 > 10.1.17.11: ICMP echo request, id 1, seq 1063, length 40
10:51:43.912030 IP 10.3.0.23 > 10.1.17.11: ICMP echo request, id 1, seq 1064, length 40
10:52:05.271357 IP 10.3.0.23.62734 > 10.1.17.11.telnet: Flags [S], seq 3199302705, win 8192, options [mss 1350,nop,wscale 8,nop,nop,sackOK], length 0
10:52:05.772457 IP 10.3.0.23.62734 > 10.1.17.11.telnet: Flags [S], seq 3199302705, win 8192, options [mss 1350,nop,wscale 8,nop,nop,sackOK], length 0
10:52:06.274356 IP 10.3.0.23.62734 >



DHCP debugging with tcpdump
Edit 
Share 

tcpdump filter to match DHCP packets including a specific Client MAC Address: 
tcpdump -i br0 -vvv -s 1500 '((port 67 or port 68) and (udp[38:4] = 0x3e0ccf08))'
tcpdump filter to capture packets sent by the client (DISCOVER, REQUEST, INFORM): 
tcpdump -i br0 -vvv -s 1500 '((port 67 or port 68) and (udp[8:1] = 0x1))'

From <https://sysadmin.fandom.com/wiki/DHCP_debugging_with_tcpdump> 


nohup tcpdump -n -i eth1 > tcpdump-eth1.txt 2>/dev/null &
[1] 10783 
ping -I eth1 -c 3 192.168.20.1 
[root@finance-server1 ~]# jobs
[1]+ Running nohup tcpdump -n -i eth1 > tcpdump-eth1.txt 2> /dev/null & 
[root@finance-server1 ~]# kill %1 




# dump k vào port 22

tcpdump -vvAs0 not port 22 -v -n -w dnsdump


