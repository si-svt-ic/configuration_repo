#### calico manifest


    - name: CALICO_DISABLE_FILE_LOGGING
      value: "true"
    - name: FELIX_DEFAULTENDPOINTTOHOSTACTION
      value: RETURN
    - name: FELIX_HEALTHHOST
      value: localhost
    - name: FELIX_IPTABLESBACKEND
      value: Legacy
    - name: FELIX_IPTABLESLOCKTIMEOUTSECS
      value: "10"
    - name: CALICO_IPV4POOL_IPIP <-----
      value: "Off"
    - name: FELIX_IPV6SUPPORT
      value: "False"
    - name: FELIX_LOGSEVERITYSCREEN
      value: info
    - name: CALICO_STARTUP_LOGLEVEL
      value: error
    - name: FELIX_USAGEREPORTINGENABLED
      value: "False"
    - name: FELIX_CHAININSERTMODE
      value: Insert
    - name: FELIX_PROMETHEUSMETRICSENABLED
      value: "False"
    - name: FELIX_PROMETHEUSMETRICSPORT
      value: "9091"
    - name: FELIX_PROMETHEUSGOMETRICSENABLED
      value: "True"
    - name: FELIX_PROMETHEUSPROCESSMETRICSENABLED
      value: "True"
    - name: NODEIP


#### bird config


  k8s_calico-node_calico-node-nxg9s_kube-system_8a04e6cc-8b36-4d3c-b7c7-2d5628c320b8_1586
  sudo docker exec -it 6d8f61753395 /bin/bash 
  cat bird.cfg
    
    # ------------- Node-to-node mesh -------------





    # For peer /host/nvd-master1/ip_addr_v4
    protocol bgp Mesh_192_168_30_123 from bgp_template {
      neighbor 192.168.30.123 port 179 as 64512;
    }



    # For peer /host/nvd-master2/ip_addr_v4
    protocol bgp Mesh_192_168_30_124 from bgp_template {
      neighbor 192.168.30.124 port 179 as 64512;
    }



    # For peer /host/nvd-master3/ip_addr_v4
    protocol bgp Mesh_192_168_30_125 from bgp_template {
      neighbor 192.168.30.125 port 179 as 64512;
    }



    # For peer /host/nvd-worker1/ip_addr_v4
    # Skipping ourselves (192.168.30.126)




    # For peer /host/nvd-worker2/ip_addr_v4
    protocol bgp Mesh_192_168_30_127 from bgp_template {
      neighbor 192.168.30.127 port 179 as 64512;
      passive on; # Mesh is unidirectional, peer will connect to us.
    }



    # For peer /host/nvd-worker3/ip_addr_v4
    protocol bgp Mesh_192_168_30_128 from bgp_template {
      neighbor 192.168.30.128 port 179 as 64512;
      passive on; # Mesh is unidirectional, peer will connect to us.
    }



    # ------------- Global peers -------------
    # No global peers configured.


    # ------------- Node-specific peers -------------

    # No node-specific peers configured.

#### deployment review

    [cloud@nvd-master1 ~]$ calicoctl get workloadendpoints
    WORKLOAD                              NODE          NETWORKS          INTERFACE         
    busybox-deployment-654565d6ff-49d9n   nvd-master2   10.233.84.26/32   cali69ccb8e6fa3   
    busybox-deployment-654565d6ff-bk8qk   nvd-master1   10.233.90.11/32   calia58f2b36532   

    [cloud@nvd-master1 ~]$ sudo docker exec -it c49e52d43732 /bin/sh
    # ip route
    default via 169.254.1.1 dev eth0 
    169.254.1.1 dev eth0 scope link 

    / # ip -4 a
    1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue qlen 1000
        inet 127.0.0.1/8 scope host lo
          valid_lft forever preferred_lft forever
    4: eth0@if10: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1480 qdisc noqueue 
        inet 10.233.90.11/32 brd 10.233.90.11 scope global eth0
          valid_lft forever preferred_lft forever


    [cloud@nvd-master1 ~]$ ip route
    default via 192.168.30.1 dev ens192 proto static metric 100 
    10.233.84.0/24 via 192.168.30.124 dev tunl0 proto bird onlink 
    blackhole 10.233.90.0/24 proto bird 
    10.233.90.9 dev cali4edba655bac scope link 
    10.233.90.10 dev cali71b6da682d7 scope link 
    10.233.90.11 dev calia58f2b36532 scope link 
    10.233.109.0/24 via 192.168.30.125 dev tunl0 proto bird onlink 
    10.233.118.0/24 via 192.168.30.127 dev tunl0 proto bird onlink 
    10.233.120.0/24 via 192.168.30.126 dev tunl0 proto bird onlink 
    10.233.121.0/24 via 192.168.30.128 dev tunl0 proto bird onlink 
    172.17.0.0/16 dev docker0 proto kernel scope link src 172.17.0.1 
    192.168.30.0/24 dev ens192 proto kernel scope link src 192.168.30.123 metric 100 
    [cloud@nvd-master1 ~]$       