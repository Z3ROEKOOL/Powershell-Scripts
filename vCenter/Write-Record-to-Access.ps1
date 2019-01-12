Add-PSSnapin VMware.DeployAutomation
Add-PSSnapin VMware.ImageBuilder
Add-PSSnapin VMware.VimAutomation.Core
Add-PSSnapin VMware.VimAutomation.License
Add-PSSnapin VMware.VimAutomation.Vds -erroraction 'silentlycontinue'

function connect-access ($strQuery){
    $dataSource = "C:\Users\ataylor\Desktop\lou01mtpod02vc_diagram_data.mdb"
    $dsn = "Provider=Microsoft.Jet.OLEDB.4.0; Data Source=$dataSource;"
    #$dsn = "Provider=Microsoft.ACE.OLEDB.12.0; Data Source=$dataSource;"
    $objConn = New-Object System.Data.OleDb.OleDbConnection $dsn
    $objCmd  = New-Object System.Data.OleDb.OleDbCommand $strQuery,$objConn
    $objConn.Open()
    $adapter = New-Object System.Data.OleDb.OleDbDataAdapter $objCmd
    $dataset = New-Object System.Data.DataSet
    [void] $adapter.Fill($dataSet)
    $objConn.Close()
}

function audit-vcenter ($esxhosts){
    foreach ($esxhost in $esxhosts){
        $host.ui.RawUI.WindowTitle = "Performing audit on: $esxhost"
        $vmhost = Get-VMHost -Name $esxhost.name | Get-View
        $esxmemory = $vmhost.Summary.Hardware.MemorySize
        $esxmemtogb = ($esxmemory / 1073741824)
        $esxhostname = $vmhost.Summary.Config.Name
        $esxhostmanufacturer =  $vmhost.Summary.Hardware.Vendor
        $esxhostmodel = $vmhost.Summary.Hardware.Model
        $esxhostcpu = $vmhost.Summary.Hardware.CpuModel
        $esxhostcpucores = $vmhost.Summary.Hardware.NumCpuThreads
        $esxhostnics = $vmhost.Summary.Hardware.NumNics
        $esxhostmanagementip = $vmhost.Summary.ManagementServerIp
        $esxhostevc = $vmhost.Summary.MaxEVCModeKey
        $esxhostversion = $vmhost.Config.Product.Fullname
        $strQuery = "DELETE FROM esx WHERE HostName = ('$esxhostname')"
        connect-access $strQuery
        $strQuery = "INSERT INTO esx (HostName, Manufacturer, Model, CPU, CPUCores, Memory_GB, NICS, vCenterIPaddy, EVC, Version) VALUES ('$esxhostname','$esxhostmanufacturer','$esxhostmodel','$esxhostcpu','$esxhostcpucores','$esxmemtogb','$esxhostnics','$esxhostmanagementip','$esxhostevc','$esxhostversion')"
        connect-access $strQuery
    }
}

$date = Get-Date -UFormat "%Y-%m-%d"
$server = Read-Host -Prompt 'Server name to connect to'
Connect-VIServer -Server $server -Protocol https
$esxhosts = Get-VMHost -Name *
audit-vcenter $esxhosts