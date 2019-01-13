Add-PSSnapin VMware.DeployAutomation
Add-PSSnapin VMware.ImageBuilder
Add-PSSnapin VMware.VimAutomation.Core
Add-PSSnapin VMware.VimAutomation.License
Add-PSSnapin VMware.VimAutomation.Vds -erroraction 'silentlycontinue'


[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$xaml = @"
<Window
xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
x:Name="Window"
        Title="Cloud ToolBox v1.0" Height="350" Width="525">
    <Grid Background="#FFE0E0E0">
        <TextBox x:Name="textBox" HorizontalAlignment="Left" Height="183" Margin="10,127,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="497" ScrollViewer.VerticalScrollBarVisibility="Visible"/>
        <Label x:Name="vcenter_lbl" Content="vCenter Address:" HorizontalAlignment="Left" Margin="10,30,0,0" VerticalAlignment="Top" Width="107"/>
        <Label x:Name="host_lbl" Content="ESXi Host:" HorizontalAlignment="Left" Margin="10,92,0,0" VerticalAlignment="Top" Width="107"/>
        <Label x:Name="cluster_lbl" Content="Cluster:" HorizontalAlignment="Left" Margin="10,61,0,0" VerticalAlignment="Top" Width="107"/>
        <TextBox x:Name="vcenter_txbx" HorizontalAlignment="Left" Height="23" Margin="133,33,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="238"/>
        <TextBox x:Name="cluster_txbx" HorizontalAlignment="Left" Height="23" Margin="133,61,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="238"/>
        <TextBox x:Name="esxi_txbx" HorizontalAlignment="Left" Height="23" Margin="133,91,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="238"/>
        <Button x:Name="connect_btn" Content="Connect to vCenter" HorizontalAlignment="Left" Margin="376,32,0,0" VerticalAlignment="Top" Width="131"/>
        <Button x:Name="disconnect_btn" Content="Disconnect vCenter" HorizontalAlignment="Left" Margin="376,61,0,0" VerticalAlignment="Top" Width="131"/>
        <Button x:Name="test_btn" Content="Get VM's" HorizontalAlignment="Left" Margin="385,92,0,0" VerticalAlignment="Top" Width="75" />


        <DockPanel>
            <Menu DockPanel.Dock="Top">
                <MenuItem Header="_Tools">
                    <MenuItem x:Name="HA_restarts" Header="_Check for HA Restarts"/>
                    <MenuItem Header="_TSO/LRO">
                        <MenuItem x:Name="check_tso" Header="_Check TSO/LRO"/>
                        <MenuItem x:Name="disable_tso" Header="_Disable TSO/LRO"/>
                    </MenuItem>
                    <MenuItem x:Name="rdm_check" Header="_Check for RDM Storage"/>
                    <MenuItem x:Name="perenniallyreserved" Header="_Set Perennially Reserved"/>
                </MenuItem>
                <MenuItem Header="_Help">
                    <MenuItem x:Name="HA_restarts_help" Header="_Check for HA Restarts"/>
                    <MenuItem Header="_TSO/LRO">
                        <MenuItem x:Name="check_tso_help" Header="_Check TSO/LRO"/>
                        <MenuItem x:Name="disable_tso_help" Header="_Disable TSO/LRO"/>
                    </MenuItem>
                    <MenuItem x:Name="rdm_check_help" Header="_Check for RDM Storage"/>
                    <MenuItem x:Name="perenniallyreserved_help" Header="_Set Perennially Reserved"/>
                </MenuItem>
            </Menu>
            <StackPanel>
            </StackPanel>
        </DockPanel>
    </Grid>
</Window>
"@
#Read XAML
$reader=(New-Object System.Xml.XmlNodeReader $xaml) 
try{$Form=[Windows.Markup.XamlReader]::Load( $reader )}
catch{Write-Host "Unable to load Windows.Markup.XamlReader. Some possible causes for this problem include: .NET Framework is missing PowerShell must be launched with PowerShell -sta, invalid XAML code was encountered."; exit}
$xaml.SelectNodes("//*[@Name]") | %{Set-Variable -Name ($_.Name) -Value $Form.FindName($_.Name)}

#functions
function check-tso ($vmhost){
cls
$output.Text = ""
$output.text += "Checking TSO/LRO and NFS Queue Depth" + "`r`n" + "`r`n"
$UseHwTSO = (Get-AdvancedSetting -Entity $vmhost -Name "Net.UseHwTSO").Value
$Vmxnet2HwLRO = (Get-AdvancedSetting -Entity $vmhost -Name "Net.Vmxnet2HwLRO").Value
$Vmxnet3HwLRO = (Get-AdvancedSetting -Entity $vmhost -Name "Net.Vmxnet3HwLRO").Value
$VmxnetSwLROSL = (Get-AdvancedSetting -Entity $vmhost -Name "Net.VmxnetSwLROSL").Value
$Vmxnet2SwLRO = (Get-AdvancedSetting -Entity $vmhost -Name "Net.Vmxnet2SwLRO").Value
$Vmxnet3SwLRO = (Get-AdvancedSetting -Entity $vmhost -Name "Net.Vmxnet3SwLRO").Value
$TcpipDefLROEnabled = (Get-AdvancedSetting -Entity $vmhost -Name "Net.TcpipDefLROEnabled").Value
$NFSMaxQueueDepth = (Get-AdvancedSetting -Entity $vmhost -Name "NFS.MaxQueueDepth").Value
$output.text += ("UseHwTSO: " + $UseHwTSO) + "`r`n"
$output.text += ("Vmxnet2HwLRO: " + $Vmxnet2HwLRO) + "`r`n"
$output.text += ("Vmxnet3HwLRO: " + $Vmxnet3HwLRO) + "`r`n"
$output.text += ("VmxnetSwLROSL: " + $VmxnetSwLROSL) + "`r`n"
$output.text += ("Vmxnet2SwLRO: " + $Vmxnet2SwLRO) + "`r`n"
$output.text += ("Vmxnet3SwLRO: " + $Vmxnet3SwLRO) + "`r`n"
$output.text += ("TcpipDefLROEnabled: " + $TcpipDefLROEnabled) + "`r`n"
$output.text += ("NFSMaxQueueDepth: " + $NFSMaxQueueDepth) + "`r`n"
}

function disable-tso ($vmhost){
cls
$output.Text = ""
$output.text = "Setting TSO/LRO and NFS Queue Depth" + "`r`n" + "`r`n"
$UseHwTSO = Get-AdvancedSetting -Entity $vmhost -Name "Net.UseHwTSO" | Set-AdvancedSetting -Value '0' -Confirm:$false
$Vmxnet2HwLRO = Get-AdvancedSetting -Entity $vmhost -Name "Net.Vmxnet2HwLRO" | Set-AdvancedSetting -Value '0' -Confirm:$false
$Vmxnet3HwLRO = Get-AdvancedSetting -Entity $vmhost -Name "Net.Vmxnet3HwLRO" | Set-AdvancedSetting -Value '0' -Confirm:$false
$VmxnetSwLROSL = Get-AdvancedSetting -Entity $vmhost -Name "Net.VmxnetSwLROSL" | Set-AdvancedSetting -Value '0' -Confirm:$false
$Vmxnet2SwLRO = Get-AdvancedSetting -Entity $vmhost -Name "Net.Vmxnet2SwLRO" | Set-AdvancedSetting -Value '0' -Confirm:$false
$Vmxnet3SwLRO = Get-AdvancedSetting -Entity $vmhost -Name "Net.Vmxnet3SwLRO" | Set-AdvancedSetting -Value '0' -Confirm:$false
$TcpipDefLROEnabled = Get-AdvancedSetting -Entity $vmhost -Name "Net.TcpipDefLROEnabled" | Set-AdvancedSetting -Value '0' -Confirm:$false
$NFSMaxQueueDepth = Get-AdvancedSetting -Entity $vmhost -Name "NFS.MaxQueueDepth" | Set-AdvancedSetting -Value '64' -Confirm:$false
$output.text += ("UseHwTSO:" + $UseHwTSO) + "`r`n"
$output.text += ("Vmxnet2HwLRO:" + $Vmxnet2HwLRO) + "`r`n"
$output.text += ("Vmxnet3HwLRO:" + $Vmxnet3HwLRO) + "`r`n"
$output.text += ("VmxnetSwLROSL:" + $VmxnetSwLROSL) + "`r`n"
$output.text += ("Vmxnet2SwLRO:" + $Vmxnet2SwLRO) + "`r`n"
$output.text += ("Vmxnet3SwLRO: " + $Vmxnet3SwLRO) + "`r`n"
$output.text += ("TcpipDefLROEnabled:  " + $TcpipDefLROEnabled) + "`r`n"
$output.text += ("NFSMaxQueueDepth:  " + $NFSMaxQueueDepth) + "`r`n"
}

function test ($vmhost){
cls
$testcommand = ''
$output.Text = ""
$output.text = "Getting a list of VM's" + "`r`n" + "`r`n"
$testcommand = Get-VM -Name * | Out-String
$output.text += ($testcommand) + "`r`n"
}

function ha_restart_check {
$output.Text += Get-Cluster $cluster.Text | Get-VM | Get-VIEvent | where {$_.FullFormattedMessage -match "vSphere HA restarted virtual machine"} | select ObjectName,@{N="IP addr";E={(Get-view -Id $_.Vm.Vm).Guest.IpAddress}},CreatedTime,FullFormattedMessage | Out-String
}

function fn_rdm_check {
$output.text += Get-VM | Get-HardDisk -DiskType "RawPhysical","RawVirtual" | Select Parent,Name,DiskType,ScsiCanonicalName,DeviceName | fl | Out-String
}

function perennially-reserved{
$timestamp = Get-Date -format "yyyyMMdd-HH.mm"
$startdir = "c:\temp"
$csvfile = "$startdir\rdmsettings-$timestamp.csv"
 
# Scipt functions
# Note that you can suppress output from commands using | Out-Null
Function logger ($message) {Write-Host -ForegroundColor Green (Get-Date -format "yyyyMMdd-HH.mm.ss") "$message" | Out-String `n}
Function loggeralert ($message) {Write-Host -ForegroundColor Red (Get-Date -format "yyyyMMdd-HH.mm.ss") "$message" | Out-String `n}
 
# Define csv table
$myTable = @()
 
logger "Starting to create a csv file. This might take a while."
 
foreach ($vm in (get-cluster $cluster.text | Get-VM | Get-HardDisk -DiskType "RawPhysical","RawVirtual")){
 
   $RDMInfo = "" |select-Object VMName,VMClusterName,DiskType,ScsiCanonicalName
 
   $RDMInfo.VMName = $vm.Parent
   $RDMInfo.VMClusterName = Get-VM $vm.Parent | Get-Cluster
   $RDMInfo.DiskType = $vm.DiskType
   $RDMInfo.ScsiCanonicalName = $vm.ScsiCanonicalName
 
$myTable += $RDMInfo
}
 
$myTable |Export-csv -NoTypeInformation $csvfile
 
logger "Finished creating csv file. Now filtering out RDMs that are not part of MSCS."
 
$allrdms = Import-Csv $csvfile
$duprdms = Import-Csv $csvfile | Group-Object ScsiCanonicalName -noElement | where {$_.count -gt 1}


logger "Starting to set the Perennially Reserved option on:"
 
ForEach ($rdm in $duprdms){
   $Cluster = ($allrdms | where {$_.ScsiCanonicalName -eq $rdm.Name} | select VMClusterName | Select -First 1).VMClusterName
   $rdmdisk = $rdm.Name
   ForEach ($esxihost in (Get-Cluster $Cluster | Get-VMHost)){
   Write-Host "ESXihost = $esxihost `t RDM = $rdmdisk" | Out-String
   $myesxcli = get-esxcli -VMHost $esxihost
   $myesxcli.storage.core.device.setconfig($false, "$rdmdisk", $true)
   }
 }
}

$reader=(New-Object System.Xml.XmlNodeReader $xaml)
$Window=[Windows.Markup.XamlReader]::Load( $reader )

#Connect to Control
$vcenter = $Window.FindName('vcenter_txbx')
$cluster = $Window.FindName('cluster_txbx')
$esxhost = $Window.FindName('esxi_txbx')
$output = $Window.FindName('textBox')
$connect = $Window.FindName("connect_btn")
$disconnect = $Window.FindName("disconnect_btn")
$test = $Window.FindName("test_btn")
$ha_restart = $Window.FindName("HA_restarts")
$rdmcheck = $Window.FindName("rdm_check")
$checktso = $Window.FindName("check_tso")
$disabletso = $Window.FindName("disable_tso")
$setperenniallyreserved = $Window.FindName("perenniallyreserved")
$help_ha_restart = $Window.FindName("HA_restarts_help")
$help_rdmcheck = $Window.FindName("rdm_check_help")
$help_checktso = $Window.FindName("check_tso_help")
$help_disabletso = $Window.FindName("disable_tso_help")
$help_setperenniallyreserved = $Window.FindName("perenniallyreserved_help")


#Events
$connect.add_Click({
$connectcommand = (Connect-VIServer -Server $vcenter.text -Protocol https -ErrorAction Stop)
$output.Text = ""
$output.text += ("Connected to vCenter: " + $connectcommand)
$output.text += "`r`n" + "`r`n"
})

$disconnect.add_Click({
Disconnect-VIServer -Server $vcenter.text -ErrorAction Stop -Confirm:$false
$output.Text = ""
$output.text += ("Disconnected from vCenter: " + $vcenter.text)
$output.text += "`r`n" + "`r`n"
})

$test.add_Click({
$vmhost = $esxhost.Text
$output.Text = "Test function to return VM's"
test $vmhost
})

$ha_restart.add_Click({
$output.Text = "k"
$vmcluster = $cluster.Text
$output.Text = ""
ha_restart_check $cluster.Text
})

$rdmcheck.add_Click({
$output.Text = "Looking for RDM's"
fn_rdm_check
})

$checktso.add_Click({
$vmhost = $esxhost.Text
$output.Text = ""
check-tso $vmhost
})

$disabletso.add_Click({
$vmhost = $esxhost.Text
$output.Text = ""
disable-tso $vmhost
})



# Help functions (not really functions)
$help_ha_restart.add_Click({
$output.Text = ""
$output.Text += "Check for HA Restarts." + "`r`n" + "`r`n"
$output.Text += "This function requires that the Cluster field be defined.  The ESXi host field can be left blank." + "`r`n" + "`r`n"
$output.Text += "Check for HA restarts will look at each VM within a cluster to check if it has had a recent HA event."
})

$help_rdmcheck.add_Click({
$output.Text = ""
$output.Text += "Check for RDM Storage." + "`r`n" + "`r`n"
$output.Text += "This function does not require the Cluster field or the ESXi field to be defined." + "`r`n" + "`r`n"
$output.Text += "Check for RDM Storages will look at each VM within a vCenter and report if a VM is using RDM Storage."
})

$help_checktso.add_Click({
$output.Text = ""
$output.Text += "Check TSO/LRO Settings." + "`r`n" + "`r`n"
$output.Text += "This function requires the ESXi field to be defined." + "`r`n" + "`r`n"
$output.Text += "Check TSO/LRO Settings will look at a host and report if TSO/LRO and NFS Max Queue Depth enabled.  For NFS Max Queue Depth it checks the current value."
})

$help_disabletso.add_Click({
$output.Text = ""
$output.Text += "Set TSO/LRO Settings." + "`r`n" + "`r`n"
$output.Text += "This function requires the ESXi field to be defined." + "`r`n" + "`r`n"
$output.Text += "Set TSO/LRO Settings will configure a host to disable TSO/LRO and NFS Max Queue Depth tp 64.  These are the values needed for CAS."
})

$help_setperenniallyreserved.add_Click({
$output.Text = ""
$output.Text += "Set Perennially Reserved." + "`r`n" + "`r`n"
$output.Text += "This function requires the Cluster field to be defined." + "`r`n" + "`r`n"
$output.Text += "Configures each host in a cluster to define RDM devices.  This is used to speed up the boot process when hosts have RDM's using Microsoft Clustering Service"
})

# End Help Section


$output.text += "If you are not sure which fields need to be filled out for various functions, see the Help menu." + "`r`n"
$output.text += "`r`n"
$output.text += "All functions will require connecting to the vCenter first." + "`r`n"
$output.text += "`r`n"
$output.text += "When working with multiple vCenters be sure to Disconnect from the active vCenter first." + "`r`n"
$output.text += "`r`n"
$output.text += "Otherwise variables could carry over and you may see unexpected results." + "`r`n"

$Window.ShowDialog() | Out-Null