
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
    
   