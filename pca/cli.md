
nrj6hCCNyEt53L!
# Patch 
    8/8:  3.0.2-b1081557
	29/9: 3.0.2-b776803
# PCA version
	cat /etc/pca-info.yml
	metadata:
	  - name: PCA
		version: PCA:3.0.2-b1185392
		description: PCA Management Software
		build_type: production

# to login pca-admin>
ssh pcaadmin@localhost -p 30006

====
ol8_developer
ol8_developer_EPEL

ol8_x86_64_baseos_developer


yum install -y oci-ansible-collection --enablerepo ol8_developer --enablerepo ol8_developer_EPEL

====

1.1.1.1.	Quy hoạch các dải mạng trong hệ thống

1/13 vlan 188
1/14 vlan 189

192.168.115.25


Check lại
- rule login.oracle.com
- account email cho notification


Kiểm tra kết nối UDP

	nc -s 192.168.188.4 -zvu -w 1 192.168.130.18 53


Kiểm tra kết nối TCP


	nc -s 192.168.188.4 -zvn -w 1 192.168.130.18 53
	
linux-update.oracle.com		138.1.51.46


support-bundles -m time_slice --all -s "2024-11-06T02:30:00" -e "2024-11-06T03:30:00"

https://100.96.2.32:8079/images/uln-pca-Oracle-Linux-8-2024.05.29_0.oci

support-bundles -m time_slice --all -s "2024-11-07T02:10:00" -e "2024-11-07T02:40:00"

	
Hello Dung -

To resolve this issue the cleanup from that defect needs to be completed.

1. Delete steeringpolicy ocid1.dnspolicy.AK03291451.fcc-pr-pca.wn8tb90s8334cad6xjtuqmmp6yogcbdlofvdlkyhvwb0u04tmjangglqx3xp
2. Delete steeringpolicyattachment where steeringPolicyId ='ocid1.dnspolicy.AK03291451.fcc-pr-pca.wn8tb90s8334cad6xjtuqmmp6yogcbdlofvdlkyhvwb0u04tmjangglqx3xp'
This should be attachment
ocid1.dnsattachment.AK03291451.fcc-pr-pca.dx1fepx16zc02dcxat7g06zbhz8ds94ugy8uiz1okzyf8eq5a23wyzms7jm5

Check pcazone.records and make sure there is only 1 pcacn001 TXT record in the record array, delete the one with the smaller rrsetVersion. 
You will probably need to do this by copying the whole array into an editor and deleting the record. 
Then use that updated list to set the records filed in the pcazone object using mysql.

Delete the first pcacn001 steering policy in the zone9816786.conf file.

Check the coredns/zone/zone9816786.conf file and make sure there is only 1 pcacn001 TXT record.

ADMINDBTOKEN=$(kubectl exec `kubectl get pods |grep admin |head -1 |awk '{print $1}'` -c admin -- grep -A 2 MYSQL /etc/pca3.0/secrets/vault-data | tail -1 |awk '{print $3}');mysql -S /usr/local/mysql/data/mysql.sock -u mysql_admin -p$ADMINDBTOKEN --database="pcaadmin";unset ADMINDBTOKEN
NETTOKEN=$(kubectl exec `kubectl get pods |grep pcanetwo |head -1 |awk '{print $1}'` -c networkctl -- grep -A 2 MYSQL /etc/pca3.0/secrets/vault-data | tail -1 |awk '{print $3}');mysql -S /usr/local/mysql/data/mysql.sock -u mysql_pcanetwork -p$NETTOKEN --database='pcanetwork'use pcanetwork;
show tables;


NETTOKEN=$(kubectl exec `kubectl get pods |grep pcanetwo |head -1 |awk '{print $1}'` -c networkctl -- grep -A 2 MYSQL /etc/pca3.0/secrets/vault-data | tail -1 |awk '{print $3}');mysql -S /usr/local/mysql/data/mysql.sock -u mysql_pcanetwork -p$NETTOKEN --database='pcanetwork'use pcanetwork;
show tables;
select * from service;
select * from steeringpolicy\G;
select * from steeringpolicyattachment\G;

select * from steeringpolicy where id='ocid1.dnspolicy.AK03291451.fcc-pr-pca.wn8tb90s8334cad6xjtuqmmp6yogcbdlofvdlkyhvwb0u04tmjangglqx3xp'\G;
delete from steeringpolicy where id='ocid1.dnspolicy.AK03291451.fcc-pr-pca.wn8tb90s8334cad6xjtuqmmp6yogcbdlofvdlkyhvwb0u04tmjangglqx3xp';
select * from steeringpolicyattachment where id='ocid1.dnsattachment.AK03291451.fcc-pr-pca.dx1fepx16zc02dcxat7g06zbhz8ds94ugy8uiz1okzyf8eq5a23wyzms7jm5'\G;
delete from steeringpolicyattachment where id='ocid1.dnsattachment.AK03291451.fcc-pr-pca.dx1fepx16zc02dcxat7g06zbhz8ds94ugy8uiz1okzyf8eq5a23wyzms7jm5';
select * from pcazone\G;


vi coredns/zone/zone9816786.conf

   steering pcacn001.fcc-pr-pca.pbvn.com.vn { #  ocid1.dnsattachment.AK03291451.fcc-pr-pca.dx1fepx16zc02dcxat7g06zbhz8ds94ugy8uiz1okzyf8eq5a23wyzms7jm5 <<<==== remove this block
      NS ns1.fcc-pr-pca.pbvn.com.vn                                                                                                                     <<
      TTL 30                                                                                                                                            <<
      ANSWER internal internal A 253.255.2.64                                                                                                           <<
      PRIORITY IP IN 253.255.0.0/20 internal                                                                                                            <<
      PRIORITY IP IN 253.255.128.0/17 internal                                                                                                          <<
      PRIORITY IP EQ 127.0.0.1 internal                                                                                                                 <<
      LIMIT 1                                                                                                                                           <<
   }
   steering pcacn001.fcc-pr-pca.pbvn.com.vn { #  ocid1.dnsattachment.AK03291451.fcc-pr-pca.y7ri1o0pe5v8505gdelixpb84xc918q3n3r9fx2rouqcf75yre35twl4r7ay
      NS ns1.fcc-pr-pca.pbvn.com.vn
      TTL 30
      ANSWER internal internal A 253.255.2.64
      PRIORITY IP IN 253.255.0.0/20 internal
      PRIORITY IP IN 253.255.128.0/17 internal
      PRIORITY IP EQ 127.0.0.1 internal
      LIMIT 1
   }



support-bundles -m time_slice --all -s "2024-11-10T01:30:00" -e "2024-11-10T02:10:00"
support-bundles -m time_slice --all -s "2024-11-13T06:30:00" -e "2024-11-13T11:10:00"


insert into steeringpolicyattachment(id, compartmentId, displayName, domainName, lifecycleState, steeringPolicyId, zoneId, eTag, rtypes) values ('ocid1.dnsattachment.AK03291451.fcc-pr-pca.y7ri1o0pe5v8505gdelixpb84xc918q3n3r9fx2rouqcf75yre35twl4r7ay', 'ocid1.compartment.oc1.DEFAULT', 'pcacn001.fcc-pr-pca.pbvn.com.vn', 'pcacn001.fcc-pr-pca.pbvn.com.vn', 'ACTIVE', 'ocid1.dnspolicy.AK03291451.fcc-pr-pca.wn8tb90s8334cad6xjtuqmmp6yogcbdlofvdlkyhvwb0u04tmjangglqx3xp', 'dns-zone-DEFAULT', '0f745b3d-4212-4fee-bacf-3cd7f55140de', '[]');



openssl genrsa -out uatadmin_api_key.pem 2048
chmod go-rwx uatadmin_api_key.pem
openssl rsa -pubout -in  uatadmin_api_key.pem -out uatadmin_api_key_public.pem


openssl genrsa -out key1_api_key.pem 2048
chmod go-rwx key1_api_key.pem
openssl rsa -pubout -in key1_api_key.pem -out key1_api_key_public.pem

plink.exe -ssh -i $env:homedrive$env\pca\console.ppk -P 32222 -L 5005:localhost:5005 ofidufs2rlq7hlvwwuwdw9gn8nonfl46@10.80.79.54 vnc@ocid1.instance.AK00684129.broom15.wliyvq5p4p8ds5zripnmpjaei6opkq2okyp2b5t5uyhrulr00va4ewbrsr23

===========



Rack Elevation: 
- Switch Mgmt : unavailable
- OS Base: 7.9 het support 

== act 2

NETTOKEN=$(kubectl exec `kubectl get pods |grep pcanetwo |head -1 |awk '{print $1}'` -c networkctl -- grep -A 2 MYSQL /etc/pca3.0/secrets/vault-data | tail -1 |awk '{print $3}');mysql -S /usr/local/mysql/data/mysql.sock -u mysql_pcanetwork -p$NETTOKEN --database='pcanetwork'use pcanetwork;
show tables;
select * from service;
select * from steeringpolicy\G;
select * from steeringpolicyattachment\G;

select * from steeringpolicy where id='ocid1.dnspolicy.AK03291451.fcc-pr-pca.wn8tb90s8334cad6xjtuqmmp6yogcbdlofvdlkyhvwb0u04tmjangglqx3xp'\G;
delete from steeringpolicy where id='ocid1.dnspolicy.AK03291451.fcc-pr-pca.wn8tb90s8334cad6xjtuqmmp6yogcbdlofvdlkyhvwb0u04tmjangglqx3xp';
select * from steeringpolicyattachment where id='ocid1.dnsattachment.AK03291451.fcc-pr-pca.dx1fepx16zc02dcxat7g06zbhz8ds94ugy8uiz1okzyf8eq5a23wyzms7jm5'\G;
delete from steeringpolicyattachment where id='ocid1.dnsattachment.AK03291451.fcc-pr-pca.dx1fepx16zc02dcxat7g06zbhz8ds94ugy8uiz1okzyf8eq5a23wyzms7jm5';
select * from pcazone\G;

=== act 3


mysql> select * from steeringpolicy where displayName like "pcacn001%"\G;
*************************** 1. row ***************************
                  id: ocid1.dnspolicy.AK03291451.fcc-pr-pca.6ysds7gxxrva1iuli1s5y28vcqnf7repfr7foykkg3feb6y9fun2croqrmf9
       compartmentId: ocid1.compartment.oc1.DEFAULT
         displayName: pcacn001.fcc-pr-pca.pbvn.com.vn
         timeCreated: 2024-11-05 18:08:49.975359
                eTag: 51d5f5d8-bc88-49ea-9bdf-fc18a34489c1
      lifecycleState: ACTIVE
             answers: [{"name": "internal", "pool": "internal", "rdata": "253.255.2.64", "rtype": "A"}]
healthCheckMonitorId: NULL
               rules: [{"cases": [{"answerData": [{"value": 1, "answerCondition": "answer.pool == 'internal'"}], "caseCondition": "query.client.address in (subnet '253.255.0.0/20')"}, {"answerData": [{"value": 1, "answerCondition": "answer.pool == 'internal'"}], "caseCondition": "query.client.address in (subnet '253.255.128.0/17')"}, {"answerData": [{"value": 1, "answerCondition": "answer.pool == 'internal'"}], "caseCondition": "query.client.address == (ip '127.0.0.1')"}], "ruleType": "PRIORITY"}, {"ruleType": "LIMIT", "defaultCount": 1}]
               zself: https://20180115/steeringPolicies/ocid1.dnspolicy.AK03291451.fcc-pr-pca.6ysds7gxxrva1iuli1s5y28vcqnf7repfr7foykkg3feb6y9fun2croqrmf9
            template: ROUTE_BY_IP
                 ttl: 30
1 row in set (0.00 sec)

ERROR:
No query specified

mysql> select * from steeringpolicyattachment where displayName like "pcacn001%"\G;
Empty set (0.00 sec)


update steeringpolicyattachment set steeringPolicyId=<id from step 1> where id=<id from step 2>;






*************************** 5. row ***************************
              id: ocid1.dnsattachment.AK03291451.fcc-pr-pca.dx1fepx16zc02dcxat7g06zbhz8ds94ugy8uiz1okzyf8eq5a23wyzms7jm5
   compartmentId: ocid1.compartment.oc1.DEFAULT
     displayName: pcacn001.fcc-pr-pca.pbvn.com.vn
     timeCreated: 2024-11-05 18:08:49.977687
            eTag: 51d5f5d8-bc88-49ea-9bdf-fc18a34489c1
  lifecycleState: ACTIVE
      domainName: pcacn001.fcc-pr-pca.pbvn.com.vn
          rtypes: ["A"]
           zself: https://20180115/steeringPolicyAttachments/ocid1.dnsattachment.AK03291451.fcc-pr-pca.dx1fepx16zc02dcxat7g06zbhz8ds94ugy8uiz1okzyf8eq5a23wyzms7jm5
steeringPolicyId: ocid1.dnspolicy.AK03291451.fcc-pr-pca.6ysds7gxxrva1iuli1s5y28vcqnf7repfr7foykkg3feb6y9fun2croqrmf9
          zoneId: dns-zone-DEFAULT
		  
		  
		  
		  
 =====
 
 openssl genrsa -out uatadmin_api_key.pem 2048
 chmod go-rwx uatadmin_api_key.pem
 openssl rsa -pubout -in  uatadmin_api_key.pem -out uatadmin_api_key_public.pem

