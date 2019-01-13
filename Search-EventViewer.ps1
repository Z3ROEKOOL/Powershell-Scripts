# .\Search-EventViewer.ps1 -StartTimeStamp '12-15-2018 00:00' -EndTimeStamp '12-15-2018 08:00'
param([string]$ComputerName = 'localhost', [datetime]$StartTimeStamp, [datetime]$EndTimeStamp)

$Logs = (Get-WinEvent -ListLog * -ComputerName $ComputerName | Where {$_.RecordCount}).LogName
$Filters = @{
    'StartTime' = $StartTimeStamp
    'EndTime' = $EndTimeStamp
    'LogName' = $Logs
    'Level' = 1,2,3
}


Get-WinEvent -ComputerName $ComputerName -FilterHashtable $Filters