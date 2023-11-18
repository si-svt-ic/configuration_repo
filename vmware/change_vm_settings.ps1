
 # Install module    

    Install-Module VMware.PowerCLI -Scope CurrentUser
    set-executionpolicy -executionpolicy RemoteSigned

# Connect vcenter

    Set-PowerCLIConfiguration -InvalidCertificateAction Ignore
    Connect-viserver vc1.svt.hn -Password Admin@123 -User administrator@vsphere.local

# Edit an extra config

    $vm_list = "lab1-serverf"
    foreach ($vmName in $vm_list)  
    {
        $vm = Get-View (Get-VM $vmName).ID
        Stop-VM -VM $vmName -Confirm:$False
        $vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec
        $vmConfigSpec.extraconfig += New-Object VMware.Vim.optionvalue
        $vmConfigSpec.extraconfig[0].Key="disk.EnableUUID"
        $vmConfigSpec.extraconfig[0].Value="TRUE"
        $vm.ReconfigVM($vmConfigSpec)
        Start-VM -VM $vmName -Confirm:$False
    }
    
## Network

### Create VDS Port group   

<#
 Script name: CreateVLANonStandardSwitch.ps1
 Created on: 10/26/2017
 Author: Alan Comstock, @Mr_Uptime
 Description: Adds VLANs to an existing standard switch
 Dependencies: None known
 PowerCLI Version: VMware PowerCLI 6.5 Release 1 build 4624819
 PowerShell Version: 5.1.14393.1532
 OS Version: Windows 10
#>

    Set-PowerCLIConfiguration -InvalidCertificateAction Ignore
    Connect-viserver vcenter68.nexttech.local -Password Admin@123 -User administrator@nexttech.local

    $InputFile = .\MyVLANs.csv
    $MyVLANFile = Import-CSV $InputFile
    
    ForEach ($VLAN in $MyVLANFile) {
    
        Get-VDSwitch -Name $VLAN.VDSwitch |
        New-VDPortgroup -Name $VLAN.VDPortgroup |
        Set-VDPortgroup -VlanId $VLAN.VLANid -Confirm:$false
    
    }

    \
    02
    03
    04
    05
    06
    07
    08
    09
    10
    11
    12
    13
    14
    15
    16
    17
    18
    19
    20
    21
    22
    23
    24
    25
    26
    27
 