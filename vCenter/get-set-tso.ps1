Import-Module VMware.VimAutomation.Core
$server = ''
$esxhost = ''
$server = Read-Host -Prompt 'Enter a vCenter to connect to'
$esxhost = Read-Host -Prompt 'Enter an ESXi host'
Try
{
    Connect-VIServer -Server $server -Protocol https -ErrorAction Stop
} Catch {
    Write-Host 'Failed to connect to vCenter'
    Write-Host ''
    Write-host $_.Exception.Message
}


function Show-Menu{
    cls
    write-host "vCenter: " $server
    Write-Host "ESXi host: " $esxhost
    Write-Host ''
    Write-Host "1: Press '1' to check TSO/LRO"
    Write-Host "2: Press '2' to disable TSO/LRO"
    Write-Host "3: Press '3' Enter new ESxi host"
    Write-Host "q: Press 'q' to quit."
}

function check-tso{
    cls
    Write-Host "`nGathering Advanced Settings for LRO, TSO, and NFS Queue Depth.   Please wait...`n" -ForegroundColor Cyan
    get-VMHostAdvancedConfiguration -vmhost $esxhost -Name "Net.UseHwTSO"
    get-VMHostAdvancedConfiguration -vmhost $esxhost -Name "Net.Vmxnet2HwLRO"
    get-VMHostAdvancedConfiguration -vmhost $esxhost -Name "Net.Vmxnet3HwLRO"
    get-VMHostAdvancedConfiguration -vmhost $esxhost -Name "Net.VmxnetSwLROSL"
    get-VMHostAdvancedConfiguration -vmhost $esxhost -Name "Net.Vmxnet2SwLRO"
    get-VMHostAdvancedConfiguration -vmhost $esxhost -Name "Net.Vmxnet3SwLRO"
    get-VMHostAdvancedConfiguration -vmhost $esxhost -Name "Net.TcpipDefLROEnabled"
    get-VMHostAdvancedConfiguration -vmhost $esxhost -Name "NFS.MaxQueueDepth"
}

function disable-tso{
    cls
    Write-Host "Disabling Advanced Settings for LRO, TSO, and NFS Queue Depth.   Please wait...`n" -ForegroundColor Cyan
    Get-AdvancedSetting -Entity $esxhost -Name "Net.UseHwTSO" | Set-AdvancedSetting -Value '0' -Confirm:$false -ErrorAction Ignore
    Get-AdvancedSetting -Entity $esxhost -Name "Net.Vmxnet2HwLRO" | Set-AdvancedSetting -Value '0' -Confirm:$false -ErrorAction Ignore
    Get-AdvancedSetting -Entity $esxhost -Name "Net.Vmxnet3HwLRO" | Set-AdvancedSetting -Value '0' -Confirm:$false -ErrorAction Ignore
    Get-AdvancedSetting -Entity $esxhost -Name "Net.VmxnetSwLROSL" | Set-AdvancedSetting -Value '0' -Confirm:$false -ErrorAction Ignore
    Get-AdvancedSetting -Entity $esxhost -Name "Net.Vmxnet2SwLRO" | Set-AdvancedSetting -Value '0' -Confirm:$false -ErrorAction Ignore
    Get-AdvancedSetting -Entity $esxhost -Name "Net.Vmxnet3SwLRO" | Set-AdvancedSetting -Value '0' -Confirm:$false -ErrorAction Ignore
    Get-AdvancedSetting -Entity $esxhost -Name "Net.TcpipDefLROEnabled" | Set-AdvancedSetting -Value '0' -Confirm:$false -ErrorAction Ignore
    Get-AdvancedSetting -Entity $esxhost -Name "NFS.MaxQueueDepth" | Set-AdvancedSetting -Value '64' -Confirm:$false -ErrorAction Ignore
}

do{
Show-Menu
$input = Read-Host "Please make a selection"
switch ($input)
{
'1'
{
check-tso
}
'2'
{
disable-tso
}
'3'
{
$esxhost = ''
$esxhost = Read-Host -Prompt 'Enter an ESXi host'
}
'q'
{
return
}
}
pause
}
until ($input -eq 'q')