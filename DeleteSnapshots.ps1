###################################################################
#Script Name	: DeleteSnapshots.ps1
#Description	: Script to delete snapshots from VMware vCenter                                                                                
#Args           : 
#Author       	: Ibrahim Geronimo
#Email         	: 
###################################################################

# Declarations
$vcsa = "vcenter.mydomain.com"

# In case of Multiple vCenter Servers use an array
<#
$vcsaList = @("vcenter1.mydomain.com", "vcenter2.mydomain.com")
#>

# Adding the PowerCLI Snapin
if(!(Get-PSSnapin | Where-Object {$_Name -eq "vmware.vimautomation.core"})) {
    try {
        Add-PSSnapin VMware.VimAutomation.core | Out-Null
    } catch {
        Write-Host "ERROR: Could not load VMware PowerCLI Snapin"
    }
}

# Set to Multiple vCenter Servers Mode
<#
if(((Get-PowerCLIConfiguration -Scope Session).DefaultVIServerMode) -ne "Multiple"){
    Set-PowerCLIConfiguration -DefaultVIServerMode Multiple -Scope User -Confirm:$false | Out-Null
    Set-PowerCLIConfiguration -DefaultVIServerMode Multiple -Scope Session -Confirm:$false | Out-Null
}
#>

# Connect to the VCSA
Connect-VIServer -Server $vcsa

# For Multiple VCSAs
<#
foreach($vcsa in $vcsaList){
    Connect-VIServer -Server $_.Name
}
#>

# Get VMs in environment
$vms = Get-VM

# Go through list
$vms.foreach({
    # Get Snapshots for current VM
    $snapshots = Get-Snapshot -VM $_.Name

    # Delete Snapshots
    $snapshots.foreach({
         # Remove current Snapshot
         Remove-Snapshot -Confirm:$false -RunAsync:$false -Snapshot $_ # RunAsync is set to fall as to not overload storage.
    })
})

# Disconnect from VCSA
Disconnect-VIServer -Server $vcsa -Confirm:$false

# Disconnect in case of Multiple VCSA
<#
foreach($vcsa in $vcsaList){
    Disconnect-VIServer -Server $vcsa -Confirm:$false
}
#>

