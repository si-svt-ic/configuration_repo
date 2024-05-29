### worker node

Rule from iptables

  [cloud@nvd-worker1 ~]$ 
  [cloud@nvd-worker1 ~]$  sudo iptables -L -n -v 
  Chain INPUT (policy ACCEPT 448 packets, 267K bytes)
  pkts bytes target     prot opt in     out     source               destination         
    15M   16G cali-INPUT  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:Cz_u1IQiXIMmKD4c */
  246K   29M ACCEPT     udp  --  *      *       0.0.0.0/0            169.254.25.10        udp dpt:53
  1344 95860 ACCEPT     tcp  --  *      *       0.0.0.0/0            169.254.25.10        tcp dpt:53
  7455K   11G TWISTLOCK-NET-INPUT  all  --  *      *       0.0.0.0/0            0.0.0.0/0           
  7463K   11G KUBE-FIREWALL  all  --  *      *       0.0.0.0/0            0.0.0.0/0           

  Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
  pkts bytes target     prot opt in     out     source               destination         
    14M   28G cali-FORWARD  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:wUHhoiAYhphO9Mso */
  39485 2831K KUBE-FORWARD  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* kubernetes forwarding rules */
  39485 2831K DOCKER-USER  all  --  *      *       0.0.0.0/0            0.0.0.0/0           
  39485 2831K ACCEPT     all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:S93hcgKJrXEqnTfs */ /* Policy explicitly accepted packet. */ mark match 0x10000/0x10000

  Chain OUTPUT (policy ACCEPT 505 packets, 208K bytes)
  pkts bytes target     prot opt in     out     source               destination         
    15M 4236M cali-OUTPUT  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:tVnHkvAo15HuiPy0 */
  246K   52M ACCEPT     udp  --  *      *       169.254.25.10        0.0.0.0/0            udp spt:53
    897 86740 ACCEPT     tcp  --  *      *       169.254.25.10        0.0.0.0/0            tcp spt:53
    12M 3019M TWISTLOCK-NET-OUTPUT  all  --  *      *       0.0.0.0/0            0.0.0.0/0           
    12M 3022M KUBE-FIREWALL  all  --  *      *       0.0.0.0/0            0.0.0.0/0           

  Chain DOCKER-USER (1 references)
  pkts bytes target     prot opt in     out     source               destination         
  39485 2831K RETURN     all  --  *      *       0.0.0.0/0            0.0.0.0/0           

  Chain KUBE-FIREWALL (2 references)
  pkts bytes target     prot opt in     out     source               destination         
      0     0 DROP       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* kubernetes firewall for dropping marked packets */ mark match 0x8000/0x8000
      0     0 DROP       all  --  *      *      !127.0.0.0/8          127.0.0.0/8          /* block incoming localnet connections */ ! ctstate RELATED,ESTABLISHED,DNAT

  Chain KUBE-FORWARD (1 references)
  pkts bytes target     prot opt in     out     source               destination         
      0     0 ACCEPT     all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* kubernetes forwarding rules */ mark match 0x4000/0x4000
      0     0 ACCEPT     all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* kubernetes forwarding conntrack pod source rule */ ctstate RELATED,ESTABLISHED
      0     0 ACCEPT     all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* kubernetes forwarding conntrack pod destination rule */ ctstate RELATED,ESTABLISHED

  Chain KUBE-KUBELET-CANARY (0 references)
  pkts bytes target     prot opt in     out     source               destination         

  Chain TWISTLOCK-NET-INPUT (1 references)
  pkts bytes target     prot opt in     out     source               destination         
      0     0 REJECT     tcp  --  *      *       0.0.0.0/0            192.168.30.0/24      tcp flags:0x17/0x02 mark match 0x10101010 /* TWISTLOCK-RULE */ reject-with tcp-reset
      0     0 REJECT     tcp  --  *      *       0.0.0.0/0            127.0.0.0/8          tcp flags:0x17/0x02 mark match 0x10101010 /* TWISTLOCK-RULE */ reject-with tcp-reset

  Chain TWISTLOCK-NET-OUTPUT (1 references)
  pkts bytes target     prot opt in     out     source               destination         
      0     0 REJECT     tcp  --  *      *       192.168.30.0/24      0.0.0.0/0            tcp flags:0x17/0x02 mark match 0x10101010 /* TWISTLOCK-RULE */ reject-with tcp-reset
      0     0 REJECT     tcp  --  *      *       127.0.0.0/8          0.0.0.0/0            tcp flags:0x17/0x02 mark match 0x10101010 /* TWISTLOCK-RULE */ reject-with tcp-reset

  Chain cali-FORWARD (1 references)
  pkts bytes target     prot opt in     out     source               destination         
    14M   28G MARK       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:vjrMJCRpqwy5oRoX */ MARK and 0xfff1ffff
    14M   28G cali-from-hep-forward  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:A_sPAO0mcxbT9mOV */ mark match 0x0/0x10000
  6009K   16G cali-from-wl-dispatch  all  --  cali+  *       0.0.0.0/0            0.0.0.0/0            /* cali:8ZoYfO5HKXWbB3pk */
  7560K   12G cali-to-wl-dispatch  all  --  *      cali+   0.0.0.0/0            0.0.0.0/0            /* cali:jdEuaPBe14V2hutn */
  39485 2831K cali-to-hep-forward  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:12bc6HljsMKsmfr- */
  39485 2831K cali-cidr-block  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:NOSxoaGx8OIstr1z */

  Chain cali-INPUT (1 references)
  pkts bytes target     prot opt in     out     source               destination         
  2471K 4087M ACCEPT     4    --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:PajejrV4aFdkZojI */ /* Allow IPIP packets from Calico hosts */ match-set cali40all-hosts-net src ADDRTYPE match dst-type LOCAL
      0     0 DROP       4    --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:_wjq-Yrma8Ly1Svo */ /* Drop IPIP packets from non-Calico hosts */
    12M   12G MARK       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:ss8lEMQsXi-s6qYT */ MARK and 0xfffff
    12M   12G cali-forward-check  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:PgIW-V0nEjwPhF_8 */
  285K   17M RETURN     all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:QMJlDwlS0OjHyfMN */ mark match ! 0x0/0xfff00000
  4869K  601M cali-wl-to-host  all  --  cali+  *       0.0.0.0/0            0.0.0.0/0           [goto]  /* cali:nDRe73txrna-aZjG */
      0     0 ACCEPT     all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:iX2AYvqGXaVqwkro */ mark match 0x10000/0x10000
  7166K   11G MARK       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:bhpnxD5IRtBP8KW0 */ MARK and 0xfff0ffff
  7166K   11G cali-from-host-endpoint  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:H5_bccAbHV0sooVy */
      0     0 ACCEPT     all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:inBL01YlfurT0dbI */ /* Host endpoint policy accepted packet. */ mark match 0x10000/0x10000

  Chain cali-OUTPUT (1 references)
  pkts bytes target     prot opt in     out     source               destination         
      0     0 ACCEPT     all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:Mq1_rAdXXH3YkrzW */ mark match 0x10000/0x10000
  10334  740K cali-forward-endpoint-mark  all  --  *      *       0.0.0.0/0            0.0.0.0/0           [goto]  /* cali:5Z67OUUpTOM7Xa1a */ mark match ! 0x0/0xfff00000
  1998K  640M RETURN     all  --  *      cali+   0.0.0.0/0            0.0.0.0/0            /* cali:M2Wf0OehNdig8MHR */
  2393K 1309M ACCEPT     4    --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:AJBkLho_0Qd8LNr3 */ /* Allow IPIP packets to other Calico hosts */ match-set cali40all-hosts-net dst ADDRTYPE match src-type LOCAL
    10M 2431M MARK       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:iz2RWXlXJDUfsLpe */ MARK and 0xfff0ffff
    10M 2431M cali-to-host-endpoint  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:hXojbnLundZDgZyw */
      0     0 ACCEPT     all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:wankpMDC2Cy1KfBv */ /* Host endpoint policy accepted packet. */ mark match 0x10000/0x10000

  Chain cali-cidr-block (1 references)
  pkts bytes target     prot opt in     out     source               destination         

  Chain cali-forward-check (1 references)
  pkts bytes target     prot opt in     out     source               destination         
    11M   12G RETURN     all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:Pbldlb4FaULvpdD8 */ ctstate RELATED,ESTABLISHED
  274K   16M cali-set-endpoint-mark  tcp  --  *      *       0.0.0.0/0            0.0.0.0/0           [goto]  /* cali:ZD-6UxuUtGW-xtzg */ /* To kubernetes NodePort service */ multiport dports 30000:32767 match-set cali40this-host dst
      0     0 cali-set-endpoint-mark  udp  --  *      *       0.0.0.0/0            0.0.0.0/0           [goto]  /* cali:CbPfUajQ2bFVnDq4 */ /* To kubernetes NodePort service */ multiport dports 30000:32767 match-set cali40this-host dst
  11108  993K cali-set-endpoint-mark  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:jmhU0ODogX-Zfe5g */ /* To kubernetes service */ ! match-set cali40this-host dst

  Chain cali-forward-endpoint-mark (1 references)
  pkts bytes target     prot opt in     out     source               destination         
  10332  740K cali-from-endpoint-mark  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:O0SmFDrnm7KggWqW */ mark match ! 0x100000/0xfff00000
    32  2252 cali-to-wl-dispatch  all  --  *      cali+   0.0.0.0/0            0.0.0.0/0            /* cali:aFl0WFKRxDqj8oA6 */
  10255  737K cali-to-hep-forward  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:AZKVrO3i_8cLai5f */
  10255  737K MARK       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:96HaP1sFtb-NYoYA */ MARK and 0xfffff
  10255  737K ACCEPT     all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:VxO6hyNWz62YEtul */ /* Policy explicitly accepted packet. */ mark match 0x10000/0x10000

  Chain cali-from-endpoint-mark (1 references)
  pkts bytes target     prot opt in     out     source               destination         
      0     0 cali-fw-cali27d5a8fe8ae  all  --  *      *       0.0.0.0/0            0.0.0.0/0           [goto]  /* cali:yrNYN7JSyKTMrK2e */ mark match 0xd8e00000/0xfff00000
    48  3392 cali-fw-cali2aef8851418  all  --  *      *       0.0.0.0/0            0.0.0.0/0           [goto]  /* cali:Mof1pl96ntHWNQs1 */ mark match 0xef300000/0xfff00000
      0     0 cali-fw-cali7aefa6d70b6  all  --  *      *       0.0.0.0/0            0.0.0.0/0           [goto]  /* cali:P5K9PLTqVKy5i_1_ */ mark match 0x78900000/0xfff00000
    12   864 cali-fw-cali9819c942018  all  --  *      *       0.0.0.0/0            0.0.0.0/0           [goto]  /* cali:fQ0ik3KiJzTh9I70 */ mark match 0x7ea00000/0xfff00000
      0     0 cali-fw-calia839c1cc9c9  all  --  *      *       0.0.0.0/0            0.0.0.0/0           [goto]  /* cali:gitZnAAukiLAmCUI */ mark match 0xcaa00000/0xfff00000
      0     0 DROP       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:tej56hiPcjcRGpe6 */ /* Unknown interface */

  Chain cali-from-hep-forward (1 references)
  pkts bytes target     prot opt in     out     source               destination         

  Chain cali-from-host-endpoint (1 references)
  pkts bytes target     prot opt in     out     source               destination         

  Chain cali-from-wl-dispatch (2 references)
  pkts bytes target     prot opt in     out     source               destination         
  70471  106M cali-from-wl-dispatch-2  all  --  cali2+ *       0.0.0.0/0            0.0.0.0/0           [goto]  /* cali:fB9Zj6ek3X-WcdQa */
  2620  611K cali-fw-cali7aefa6d70b6  all  --  cali7aefa6d70b6 *       0.0.0.0/0            0.0.0.0/0           [goto]  /* cali:Y-YCo-lrbr8ubEc0 */
  37259  170M cali-fw-cali9819c942018  all  --  cali9819c942018 *       0.0.0.0/0            0.0.0.0/0           [goto]  /* cali:0C_IyHuMKlJZbFOB */
  4507  556K cali-fw-calia839c1cc9c9  all  --  calia839c1cc9c9 *       0.0.0.0/0            0.0.0.0/0           [goto]  /* cali:EwvdMvMjiZ68lqHV */
      0     0 DROP       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:I7vxl4VhpuAWVxE7 */ /* Unknown interface */

  Chain cali-from-wl-dispatch-2 (1 references)
  pkts bytes target     prot opt in     out     source               destination         
    329 27636 cali-fw-cali27d5a8fe8ae  all  --  cali27d5a8fe8ae *       0.0.0.0/0            0.0.0.0/0           [goto]  /* cali:NE5q7vY2OTZu5i8T */
  27468   88M cali-fw-cali2aef8851418  all  --  cali2aef8851418 *       0.0.0.0/0            0.0.0.0/0           [goto]  /* cali:Qg36YK9Lij1X-oHQ */
      0     0 DROP       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:m9pbfem2W7SQRLQk */ /* Unknown interface */

  Chain cali-fw-cali27d5a8fe8ae (2 references)
  pkts bytes target     prot opt in     out     source               destination         
      0     0 ACCEPT     all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:w6lmsvcjCrMGZ-WS */ ctstate RELATED,ESTABLISHED
      0     0 DROP       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:aapWQyyOnyQggC_3 */ ctstate INVALID
    329 27636 MARK       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:rmmQDw0oFZJPim23 */ MARK and 0xfffeffff
      0     0 DROP       udp  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:dqNYevjZ6PmGydIg */ /* Drop VXLAN encapped packets originating in workloads */ multiport dports 4789
      0     0 DROP       4    --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:pMKcmPaVYvOJmErj */ /* Drop IPinIP encapped packets originating in workloads */
    329 27636 cali-pro-kns.kube-system  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:JV3Hc69opbne2PyH */
    329 27636 RETURN     all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:PV_Tj1hxltRhx5CY */ /* Return if profile accepted */ mark match 0x10000/0x10000
      0     0 cali-pro-_hNSGmJYNT8uLIzxesP  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:LsKJg32C-aTJmXmA */
      0     0 RETURN     all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:rZTWOVNl1iKMJU17 */ /* Return if profile accepted */ mark match 0x10000/0x10000
      0     0 DROP       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:wkiK15tTk16jHEWZ */ /* Drop if no profiles matched */

  Chain cali-fw-cali2aef8851418 (2 references)
  pkts bytes target     prot opt in     out     source               destination         
  1978K 6277M ACCEPT     all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:07k4opg0uWc0Re17 */ ctstate RELATED,ESTABLISHED
      2    80 DROP       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:HHEsWHBtniB2cnha */ ctstate INVALID
  23839 2089K MARK       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:xPj-gluav4A4LplN */ MARK and 0xfffeffff
      0     0 DROP       udp  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:tC975qvleqP7XgNH */ /* Drop VXLAN encapped packets originating in workloads */ multiport dports 4789
      0     0 DROP       4    --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:0aXABMUolSP5HttM */ /* Drop IPinIP encapped packets originating in workloads */
  23839 2089K cali-pro-kns.monitoring  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:4h02po6CQFQWBfYG */
  23839 2089K RETURN     all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:7QBi-LMePshnCFoC */ /* Return if profile accepted */ mark match 0x10000/0x10000
      0     0 cali-pro-_BOCEwdOoL92HajX9Ru  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:uovgPKPrWOLC4iPI */
      0     0 RETURN     all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:gasc1f-vWi75OW0J */ /* Return if profile accepted */ mark match 0x10000/0x10000
      0     0 DROP       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:FIIm2tv4FhLaRf6u */ /* Drop if no profiles matched */

  Chain cali-fw-cali7aefa6d70b6 (2 references)
  pkts bytes target     prot opt in     out     source               destination         
  2262  581K ACCEPT     all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:bkExoh6m0CianV4e */ ctstate RELATED,ESTABLISHED
      0     0 DROP       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:TMrIbUGtNeKnoJOF */ ctstate INVALID
    358 29752 MARK       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:vU_EBOeLZAtXXiPI */ MARK and 0xfffeffff
      0     0 DROP       udp  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:lSH-MFFhsm6BLlrk */ /* Drop VXLAN encapped packets originating in workloads */ multiport dports 4789
      0     0 DROP       4    --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:PiSfm5lTXwM6lJvK */ /* Drop IPinIP encapped packets originating in workloads */
    358 29752 cali-pro-kns.daiminh  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:OYLDQlmDui31W9zN */
    358 29752 RETURN     all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:66LJWANQCei9YThe */ /* Return if profile accepted */ mark match 0x10000/0x10000
      0     0 cali-pro-ksa.daiminh.default  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:itBeoiherfEiB1Dx */
      0     0 RETURN     all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:Gtpzs4WOxlal2iTy */ /* Return if profile accepted */ mark match 0x10000/0x10000
      0     0 DROP       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:gACNLgVsSSxf2qIA */ /* Drop if no profiles matched */

  Chain cali-fw-cali9819c942018 (2 references)
  pkts bytes target     prot opt in     out     source               destination         
  189K  557M ACCEPT     all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:LRdlXdQrB4CW7K9S */ ctstate RELATED,ESTABLISHED
      0     0 DROP       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:GmtnJ-m0hfvnUifh */ ctstate INVALID
    137  9642 MARK       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:XTuHWGiIS8BKKLYF */ MARK and 0xfffeffff
      0     0 DROP       udp  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:Fjntk1fBL25omjh4 */ /* Drop VXLAN encapped packets originating in workloads */ multiport dports 4789
      0     0 DROP       4    --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:xI9BrKWaYNjd4LBG */ /* Drop IPinIP encapped packets originating in workloads */
    137  9642 cali-pro-kns.daiminh  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:hpVLaDHq5VeUcQjA */
    137  9642 RETURN     all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:nSmXq8tjBchtAsCC */ /* Return if profile accepted */ mark match 0x10000/0x10000
      0     0 cali-pro-_iqB0GnA-nMyiipmRa6  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:MF1yWRKN8g_irgmL */
      0     0 RETURN     all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:ID8irJ0Fpga1qFzb */ /* Return if profile accepted */ mark match 0x10000/0x10000
      0     0 DROP       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:OAHNer0PaqF6G3Va */ /* Drop if no profiles matched */

  Chain cali-fw-calia839c1cc9c9 (2 references)
  pkts bytes target     prot opt in     out     source               destination         
  335K   40M ACCEPT     all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:mUu2qCUWHm5DDaKs */ ctstate RELATED,ESTABLISHED
      4  1188 DROP       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:09T6hw1JSviLVboQ */ ctstate INVALID
  35460 5609K MARK       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:9E96RtXQAyRIYqto */ MARK and 0xfffeffff
      0     0 DROP       udp  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:OLV9srB1l7_2EbUQ */ /* Drop VXLAN encapped packets originating in workloads */ multiport dports 4789
      0     0 DROP       4    --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:DE1bafpCumcmuh9T */ /* Drop IPinIP encapped packets originating in workloads */
  35460 5609K cali-pro-kns.monitoring  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:rHKjNz2F4FLmDIpO */
  35460 5609K RETURN     all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:ScQF9jGbyM4zpfD8 */ /* Return if profile accepted */ mark match 0x10000/0x10000
      0     0 cali-pro-_UT2zSuirt4v0xQqpjp  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:Xk5bOUV1ALzqxiJk */
      0     0 RETURN     all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:jZ_bPaKWLKbiO-5c */ /* Return if profile accepted */ mark match 0x10000/0x10000
      0     0 DROP       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:Wv1GaplpN_FD6VWD */ /* Drop if no profiles matched */

  Chain cali-pri-_BOCEwdOoL92HajX9Ru (1 references)
  pkts bytes target     prot opt in     out     source               destination         

  Chain cali-pri-_UT2zSuirt4v0xQqpjp (1 references)
  pkts bytes target     prot opt in     out     source               destination         

  Chain cali-pri-_hNSGmJYNT8uLIzxesP (1 references)
  pkts bytes target     prot opt in     out     source               destination         

  Chain cali-pri-_iqB0GnA-nMyiipmRa6 (1 references)
  pkts bytes target     prot opt in     out     source               destination         

  Chain cali-pri-kns.daiminh (2 references)
  pkts bytes target     prot opt in     out     source               destination         
    243 16636 MARK       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:sND_DPc3o9dH0g40 */ MARK or 0x10000
    243 16636 RETURN     all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:lCfdR3TT6pYyK1D9 */ mark match 0x10000/0x10000

  Chain cali-pri-kns.kube-system (1 references)
  pkts bytes target     prot opt in     out     source               destination         
      0     0 MARK       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:zoH5gU6U55FKZxEo */ MARK or 0x10000
      0     0 RETURN     all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:bcGRIJcyOS9dgBiB */ mark match 0x10000/0x10000

  Chain cali-pri-kns.monitoring (2 references)
  pkts bytes target     prot opt in     out     source               destination         
  1558  112K MARK       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:6Jg0bcUe-W95x053 */ MARK or 0x10000
  1558  112K RETURN     all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:Ib2KQsRqEwfIXcDC */ mark match 0x10000/0x10000

  Chain cali-pri-ksa.daiminh.default (1 references)
  pkts bytes target     prot opt in     out     source               destination         

  Chain cali-pro-_BOCEwdOoL92HajX9Ru (1 references)
  pkts bytes target     prot opt in     out     source               destination         

  Chain cali-pro-_UT2zSuirt4v0xQqpjp (1 references)
  pkts bytes target     prot opt in     out     source               destination         

  Chain cali-pro-_hNSGmJYNT8uLIzxesP (1 references)
  pkts bytes target     prot opt in     out     source               destination         

  Chain cali-pro-_iqB0GnA-nMyiipmRa6 (1 references)
  pkts bytes target     prot opt in     out     source               destination         

  Chain cali-pro-kns.daiminh (2 references)
  pkts bytes target     prot opt in     out     source               destination         
    701 58767 MARK       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:1JbAnl2G1aO7-OIS */ MARK or 0x10000
    701 58767 RETURN     all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:MuBuh2tL4lPCIbHE */ mark match 0x10000/0x10000

  Chain cali-pro-kns.kube-system (1 references)
  pkts bytes target     prot opt in     out     source               destination         
    329 27636 MARK       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:-50oJuMfLVO3LkBk */ MARK or 0x10000
    329 27636 RETURN     all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:ztVPKv1UYejNzm1g */ mark match 0x10000/0x10000

  Chain cali-pro-kns.monitoring (2 references)
  pkts bytes target     prot opt in     out     source               destination         
  59299 7698K MARK       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:ygA0X70Z0o8BmXwl */ MARK or 0x10000
  59299 7698K RETURN     all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:GoDpz1laQ6A5-7HK */ mark match 0x10000/0x10000

  Chain cali-pro-ksa.daiminh.default (1 references)
  pkts bytes target     prot opt in     out     source               destination         

  Chain cali-set-endpoint-mark (3 references)
  pkts bytes target     prot opt in     out     source               destination         
    341  148K cali-set-endpoint-mark-2  all  --  cali2+ *       0.0.0.0/0            0.0.0.0/0           [goto]  /* cali:tz9NBFniulUgGBjW */
      0     0 cali-sm-cali7aefa6d70b6  all  --  cali7aefa6d70b6 *       0.0.0.0/0            0.0.0.0/0           [goto]  /* cali:IIdcC1Nc8DMJPOmV */
    16  1259 cali-sm-cali9819c942018  all  --  cali9819c942018 *       0.0.0.0/0            0.0.0.0/0           [goto]  /* cali:HhHRDuuRHawybzO0 */
      0     0 cali-sm-calia839c1cc9c9  all  --  calia839c1cc9c9 *       0.0.0.0/0            0.0.0.0/0           [goto]  /* cali:s0llq7oHvWXgtWHF */
      0     0 DROP       all  --  cali+  *       0.0.0.0/0            0.0.0.0/0            /* cali:WvxmRu87ZdkMFZfN */ /* Unknown endpoint */
    929 55894 MARK       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:5mtFm2IJrCxBoUiE */ /* Non-Cali endpoint mark */ MARK xset 0x100000/0xfff00000

  Chain cali-set-endpoint-mark-2 (1 references)
  pkts bytes target     prot opt in     out     source               destination         
    291  144K cali-sm-cali27d5a8fe8ae  all  --  cali27d5a8fe8ae *       0.0.0.0/0            0.0.0.0/0           [goto]  /* cali:1Ezy3UuQellelUY6 */
    50  3583 cali-sm-cali2aef8851418  all  --  cali2aef8851418 *       0.0.0.0/0            0.0.0.0/0           [goto]  /* cali:JdjymFzDaTn6R8OT */

  Chain cali-sm-cali27d5a8fe8ae (1 references)
  pkts bytes target     prot opt in     out     source               destination         
    291  144K MARK       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:5YcUdcJi9FRaL31s */ MARK xset 0xd8e00000/0xfff00000

  Chain cali-sm-cali2aef8851418 (1 references)
  pkts bytes target     prot opt in     out     source               destination         
  1499  108K MARK       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:wNB3cxkn8Zy4hVaZ */ MARK xset 0xef300000/0xfff00000

  Chain cali-sm-cali7aefa6d70b6 (1 references)
  pkts bytes target     prot opt in     out     source               destination         
      0     0 MARK       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:iCSqkzn6SmXohZ0r */ MARK xset 0x78900000/0xfff00000

  Chain cali-sm-cali9819c942018 (1 references)
  pkts bytes target     prot opt in     out     source               destination         
    28  2123 MARK       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:7ewcJAgujCj_O-At */ MARK xset 0x7ea00000/0xfff00000

  Chain cali-sm-calia839c1cc9c9 (1 references)
  pkts bytes target     prot opt in     out     source               destination         
      0     0 MARK       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:gDdTkl18TQmHodkw */ MARK xset 0xcaa00000/0xfff00000

  Chain cali-to-hep-forward (2 references)
  pkts bytes target     prot opt in     out     source               destination         

  Chain cali-to-host-endpoint (1 references)
  pkts bytes target     prot opt in     out     source               destination         

  Chain cali-to-wl-dispatch (2 references)
  pkts bytes target     prot opt in     out     source               destination         
  47859  197M cali-to-wl-dispatch-2  all  --  *      cali2+  0.0.0.0/0            0.0.0.0/0           [goto]  /* cali:lcQU8m6ksniK0hyh */
  1918 4744K cali-tw-cali7aefa6d70b6  all  --  *      cali7aefa6d70b6  0.0.0.0/0            0.0.0.0/0           [goto]  /* cali:sHjBqub26e0Aqggz */
  59594   32M cali-tw-cali9819c942018  all  --  *      cali9819c942018  0.0.0.0/0            0.0.0.0/0           [goto]  /* cali:oCXDKW9zR2Rn7IWw */
  2174  213K cali-tw-calia839c1cc9c9  all  --  *      calia839c1cc9c9  0.0.0.0/0            0.0.0.0/0           [goto]  /* cali:KG2GGNbgA8R8tUWX */
      0     0 DROP       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:WP0m5WF-1cf1m52x */ /* Unknown interface */

  Chain cali-to-wl-dispatch-2 (1 references)
  pkts bytes target     prot opt in     out     source               destination         
      0     0 cali-tw-cali27d5a8fe8ae  all  --  *      cali27d5a8fe8ae  0.0.0.0/0            0.0.0.0/0           [goto]  /* cali:yGP5HQI62mNC56Fw */
  20308   40M cali-tw-cali2aef8851418  all  --  *      cali2aef8851418  0.0.0.0/0            0.0.0.0/0           [goto]  /* cali:-ADzWU1f1jDfOb9A */
      0     0 DROP       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:fsUUU-snRZaOs4Bz */ /* Unknown interface */

  Chain cali-tw-cali27d5a8fe8ae (1 references)
  pkts bytes target     prot opt in     out     source               destination         
      0     0 ACCEPT     all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:ekYhYiD69aFVmfou */ ctstate RELATED,ESTABLISHED
      0     0 DROP       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:hgbGM4p9kq0dqggL */ ctstate INVALID
      0     0 MARK       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:fpQweqScVnpwHo82 */ MARK and 0xfffeffff
      0     0 cali-pri-kns.kube-system  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:HFsTPpW9NGWfqo_4 */
      0     0 RETURN     all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:xS5qY_gK4JxZVRaH */ /* Return if profile accepted */ mark match 0x10000/0x10000
      0     0 cali-pri-_hNSGmJYNT8uLIzxesP  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:7AtRDBn1ObMh7oUI */
      0     0 RETURN     all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:tCDnH1Aq42zKQNEq */ /* Return if profile accepted */ mark match 0x10000/0x10000
      0     0 DROP       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:dy8lYVbrHNexs9Cb */ /* Drop if no profiles matched */

  Chain cali-tw-cali2aef8851418 (1 references)
  pkts bytes target     prot opt in     out     source               destination         
  1474K 2810M ACCEPT     all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:0_sFanOv5wUowAHa */ ctstate RELATED,ESTABLISHED
    21   840 DROP       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:PQO_gftIqPmTDusR */ ctstate INVALID
    27  1944 MARK       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:RISNr9_78G3ezQRv */ MARK and 0xfffeffff
    27  1944 cali-pri-kns.monitoring  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:oA4PwWKQNksSzIOx */
    27  1944 RETURN     all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:t0TOx5ptnve_mPTP */ /* Return if profile accepted */ mark match 0x10000/0x10000
      0     0 cali-pri-_BOCEwdOoL92HajX9Ru  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:V5crc-eya_XD0nt7 */
      0     0 RETURN     all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:lB28l9ZFaSGDhMoQ */ /* Return if profile accepted */ mark match 0x10000/0x10000
      0     0 DROP       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:sj7iY8hmkqKni3Qq */ /* Drop if no profiles matched */

  Chain cali-tw-cali7aefa6d70b6 (1 references)
  pkts bytes target     prot opt in     out     source               destination         
  1918 4744K ACCEPT     all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:0_Kv2ESh0Iveofxm */ ctstate RELATED,ESTABLISHED
      0     0 DROP       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:pMs9Mj7avzNA-xl- */ ctstate INVALID
      0     0 MARK       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:YRLBEa-TlkUlSlOg */ MARK and 0xfffeffff
      0     0 cali-pri-kns.daiminh  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:vsuWCqWHUrq-QLxe */
      0     0 RETURN     all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:E2jggjcE0uDGwyAK */ /* Return if profile accepted */ mark match 0x10000/0x10000
      0     0 cali-pri-ksa.daiminh.default  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:yOeQnVkGP2Z6uXE2 */
      0     0 RETURN     all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:jbnUKOKCtzHX3pgO */ /* Return if profile accepted */ mark match 0x10000/0x10000
      0     0 DROP       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:dXGsN-2kbBSjeKGB */ /* Drop if no profiles matched */

  Chain cali-tw-cali9819c942018 (1 references)
  pkts bytes target     prot opt in     out     source               destination         
  160K   95M ACCEPT     all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:3uM1OF8AGyfso2AU */ ctstate RELATED,ESTABLISHED
      0     0 DROP       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:WBWzaS02B7EbGjL0 */ ctstate INVALID
    243 16636 MARK       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:-UGRVoNHQ4BtH8vf */ MARK and 0xfffeffff
    243 16636 cali-pri-kns.daiminh  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:E3KepuOR7DEFIZ8D */
    243 16636 RETURN     all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:VNbtSul9FB5p7Xcb */ /* Return if profile accepted */ mark match 0x10000/0x10000
      0     0 cali-pri-_iqB0GnA-nMyiipmRa6  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:FigMhdNUNVA9LTXl */
      0     0 RETURN     all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:3SeN0EW-bfSu9snW */ /* Return if profile accepted */ mark match 0x10000/0x10000
      0     0 DROP       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:LLSw2Z0KnnV0TKXZ */ /* Drop if no profiles matched */

  Chain cali-tw-calia839c1cc9c9 (1 references)
  pkts bytes target     prot opt in     out     source               destination         
  174K   17M ACCEPT     all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:eWbIjOnk5IYHZFK- */ ctstate RELATED,ESTABLISHED
      0     0 DROP       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:yxpiw-9wIo8BFnZl */ ctstate INVALID
  1531  110K MARK       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:RLnvQpxzDtajWvl_ */ MARK and 0xfffeffff
  1531  110K cali-pri-kns.monitoring  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:QAdakBMhgx2h1lpX */
  1531  110K RETURN     all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:fEotRR-h_tzTZFl0 */ /* Return if profile accepted */ mark match 0x10000/0x10000
      0     0 cali-pri-_UT2zSuirt4v0xQqpjp  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:6DJ5z-8uDmgdJziy */
      0     0 RETURN     all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:gxrHXP-2kynmww3h */ /* Return if profile accepted */ mark match 0x10000/0x10000
      0     0 DROP       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:NsW6Pxa8yqwxqfaO */ /* Drop if no profiles matched */

  Chain cali-wl-to-host (1 references)
  pkts bytes target     prot opt in     out     source               destination         
  4869K  601M cali-from-wl-dispatch  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:Ee9Sbo10IpVujdIY */
  252K   29M RETURN     all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:sO1YJiY1b553biDi */ /* Configured DefaultEndpointToHostAction */
  [cloud@nvd-worker1 ~]$ 