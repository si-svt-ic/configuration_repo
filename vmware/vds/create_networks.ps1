##########################################
#
# Script to create vDS Portgroups
# Created by BLiebowitz on 5/31/2017
#
# reference : https://www.reddit.com/r/vmware/comments/8hx12x/looking_for_a_powercli_script_to_change_vds/
###########################################
 
# Connect to vCenter
# Connect-viserver vCenter
 
# Set the VDS Name to variable
$vds = "VDS-VSAN"
$vdsname = get-vdswitch $vds
 
# Import the CSV of VLAN IDs, Portgroups, and # of ports
$vdsPortgroup = Import-Csv "C:\Users\Donetsk\My_Drive\MyVLANs.csv"
 
# Loop through each VLAN and create it in the vDS
foreach ($portgroup in $vdsPortgroup){
get-vdswitch $vdsname | New-VDPortgroup -Name $portgroup.pgName -NumPorts $portgroup.numports -VlanId $portgroup.vlanID
get-vdswitch $vdsname | Get-VDPortgroup -name $portgroup.pgName | Get-VDUplinkTeamingPolicy | Set-VDUplinkTeamingPolicy -ActiveUplinkPort $activeUplink -UnusedUplinkPort $UnusedUplinks
#Write-Host $portgroup.pgName
}
 
# List the vLANS after creation
# Write-Host "`nPortgroups created. Now confirming settings" -ForegroundColor Cyan
# Get-VDSwitch $vdsname | Get-VDPortgroup | select name, numports, portbinding, vlanconfiguration


