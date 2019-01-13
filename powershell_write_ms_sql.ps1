Add-PSSnapin VMware.VimAutomation.Core
Add-PSSnapin VMware.VimAutomation.Vds -erroraction 'silentlycontinue'

$SQLServer = "SQL\SQLEXPRESS"
$SQLDBName = "datastores"
$uid ="sa"
$pwd = "password"
$date_checked = Get-Date -Format g

$vcenter = 'vcenter'
Connect-VIServer -Server $vcenter -Protocol https

$datastores = Get-Datastore | where {($_.type -eq "VMFS") -or ($_.type -eq "NFS")}
foreach ($datastore in $datastores){
$datastore.Name
$datastore.State
$datastore.CapacityGB
$datastore.FreeSpaceGB
$datastore.Type
$datastore.Id

$conn = New-Object System.Data.SqlClient.SqlConnection
$conn.ConnectionString = "Server = $SQLServer; Database = $SQLDBName; User ID = $uid; Password = $pwd; Integrated Security = False;"
$conn.open()
$cmd = New-Object System.Data.SqlClient.SqlCommand
$cmd.connection = $conn
$cmd.commandtext = "INSERT INTO cloud_e (vcenter,ds_name,ds_state,ds_capacity,ds_free_space,ds_type,ds_id,record_date) VALUES('{0}','{1}','{2}','{3}','{4}','{5}','{6}','{7}')" -f $vcenter,$datastore.Name,$datastore.State,$datastore.CapacityGB,$datastore.FreeSpaceGB,$datastore.Type,$datastore.Id,$date_checked
$cmd.executenonquery()
$conn.close()
}
Disconnect-VIServer -Confirm:$false