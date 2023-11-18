#!/bin/bash

NSX_MANAGER="https://10.0.3.110/policy/api/v1/infra/segments"

segments=(
'{"display_name":"LAN_NL", "transport_zone_path": "/infra/sites/default/enforcement-points/default/transport-zones/VLAN-TZ","vlan_ids" : [ "1" ]}'
'{"display_name":"MONITOR_2", "transport_zone_path": "/infra/sites/default/enforcement-points/default/transport-zones/VLAN-TZ","vlan_ids" : [ "2" ]}'
'{"display_name":"PORT_MANAGEMENT_3", "transport_zone_path": "/infra/sites/default/enforcement-points/default/transport-zones/VLAN-TZ","vlan_ids" : [ "3" ]}'
'{"display_name":"BACKUP_6", "transport_zone_path": "/infra/sites/default/enforcement-points/default/transport-zones/VLAN-TZ","vlan_ids" : [ "6" ]}'
'{"display_name":"NEXTTECH_8", "transport_zone_path": "/infra/sites/default/enforcement-points/default/transport-zones/VLAN-TZ","vlan_ids" : [ "8" ]}'
'{"display_name":"GATEWAY_9", "transport_zone_path": "/infra/sites/default/enforcement-points/default/transport-zones/VLAN-TZ","vlan_ids" : [ "9" ]}'
'{"display_name":"DMZ_10", "transport_zone_path": "/infra/sites/default/enforcement-points/default/transport-zones/VLAN-TZ","vlan_ids" : [ "10" ]}'
'{"display_name":"NL_internalCDE_13", "transport_zone_path": "/infra/sites/default/enforcement-points/default/transport-zones/VLAN-TZ","vlan_ids" : [ "13" ]}'
'{"display_name":"NL_noneCDE_14", "transport_zone_path": "/infra/sites/default/enforcement-points/default/transport-zones/VLAN-TZ","vlan_ids" : [ "14" ]}'
'{"display_name":"NL_CDE_15", "transport_zone_path": "/infra/sites/default/enforcement-points/default/transport-zones/VLAN-TZ","vlan_ids" : [ "15" ]}'
'{"display_name":"ALEGO_16", "transport_zone_path": "/infra/sites/default/enforcement-points/default/transport-zones/VLAN-TZ","vlan_ids" : [ "16" ]}'
'{"display_name":"NL_Other_18", "transport_zone_path": "/infra/sites/default/enforcement-points/default/transport-zones/VLAN-TZ","vlan_ids" : [ "18" ]}'
'{"display_name":"XMONEY_19", "transport_zone_path": "/infra/sites/default/enforcement-points/default/transport-zones/VLAN-TZ","vlan_ids" : [ "19" ]}'
'{"display_name":"NP_Other_20", "transport_zone_path": "/infra/sites/default/enforcement-points/default/transport-zones/VLAN-TZ","vlan_ids" : [ "20" ]}'
'{"display_name":"TTOL_VIMO_21", "transport_zone_path": "/infra/sites/default/enforcement-points/default/transport-zones/VLAN-TZ","vlan_ids" : [ "21" ]}'
'{"display_name":"NP_noneCDE_22", "transport_zone_path": "/infra/sites/default/enforcement-points/default/transport-zones/VLAN-TZ","vlan_ids" : [ "22" ]}'
'{"display_name":"NP_CDE_23", "transport_zone_path": "/infra/sites/default/enforcement-points/default/transport-zones/VLAN-TZ","vlan_ids" : [ "23" ]}'
'{"display_name":"MPOS_24", "transport_zone_path": "/infra/sites/default/enforcement-points/default/transport-zones/VLAN-TZ","vlan_ids" : [ "24" ]}'
'{"display_name":"NL_noneCDE_25", "transport_zone_path": "/infra/sites/default/enforcement-points/default/transport-zones/VLAN-TZ","vlan_ids" : [ "25" ]}'
'{"display_name":"NEXTCAM_26", "transport_zone_path": "/infra/sites/default/enforcement-points/default/transport-zones/VLAN-TZ","vlan_ids" : [ "26" ]}'
'{"display_name":"NIG_Prod_27", "transport_zone_path": "/infra/sites/default/enforcement-points/default/transport-zones/VLAN-TZ","vlan_ids" : [ "27" ]}'
'{"display_name":"VP-BILLGATE_30", "transport_zone_path": "/infra/sites/default/enforcement-points/default/transport-zones/VLAN-TZ","vlan_ids" : [ "30" ]}'
'{"display_name":"DATALAKE_32", "transport_zone_path": "/infra/sites/default/enforcement-points/default/transport-zones/VLAN-TZ","vlan_ids" : [ "32" ]}'
'{"display_name":"VIMO_36", "transport_zone_path": "/infra/sites/default/enforcement-points/default/transport-zones/VLAN-TZ","vlan_ids" : [ "36" ]}'
'{"display_name":"BILLGATE_41", "transport_zone_path": "/infra/sites/default/enforcement-points/default/transport-zones/VLAN-TZ","vlan_ids" : [ "41" ]}'
'{"display_name":"NL_K8S_44", "transport_zone_path": "/infra/sites/default/enforcement-points/default/transport-zones/VLAN-TZ","vlan_ids" : [ "44" ]}'
'{"display_name":"NEXTLEND_45", "transport_zone_path": "/infra/sites/default/enforcement-points/default/transport-zones/VLAN-TZ","vlan_ids" : [ "45" ]}'
'{"display_name":"FG_K8S_46", "transport_zone_path": "/infra/sites/default/enforcement-points/default/transport-zones/VLAN-TZ","vlan_ids" : [ "46" ]}'
'{"display_name":"NP_CheckOut_47", "transport_zone_path": "/infra/sites/default/enforcement-points/default/transport-zones/VLAN-TZ","vlan_ids" : [ "47" ]}'
'{"display_name":"TEST_NL_100", "transport_zone_path": "/infra/sites/default/enforcement-points/default/transport-zones/VLAN-TZ","vlan_ids" : [ "100" ]}'
'{"display_name":"DEV_NL_101", "transport_zone_path": "/infra/sites/default/enforcement-points/default/transport-zones/VLAN-TZ","vlan_ids" : [ "101" ]}'
'{"display_name":"TEST_111", "transport_zone_path": "/infra/sites/default/enforcement-points/default/transport-zones/VLAN-TZ","vlan_ids" : [ "111" ]}'
'{"display_name":"TEST_VIMO_121", "transport_zone_path": "/infra/sites/default/enforcement-points/default/transport-zones/VLAN-TZ","vlan_ids" : [ "121" ]}'
'{"display_name":"TEST_NEXTPAY_150", "transport_zone_path": "/infra/sites/default/enforcement-points/default/transport-zones/VLAN-TZ","vlan_ids" : [ "150" ]}'
'{"display_name":"NP_VIETTEL_229", "transport_zone_path": "/infra/sites/default/enforcement-points/default/transport-zones/VLAN-TZ","vlan_ids" : [ "229" ]}'
)

for segments in "${segments[@]}";
do
curl -k -X DELETE -u "admin:Nexttech@123@Nexttech" \
       -H "Content-Type: application/json" \
       -d "$segments" \
       "$NSX_MANAGER/$(echo "$segments" | awk -F ',' '{print $1}' | awk -F ':' '{print $2}' | grep -o '[^"]*')"
done

# curl -k GET -u "admin:Nexttech@123@Nexttech" -H "Content-Type: application/json" "https://10.0.3.110/policy/api/v1/infra/segments"