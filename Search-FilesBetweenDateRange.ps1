# .\Search-FilesBetweenDateRange.ps1 -Directory 'c:\' -StartTimeStamp '12-15-2018 00:00' -EndTimeStamp '12-15-2018 08:00'
param([string]$Directory, [datetime]$StartTimeStamp, [datetime]$EndTimeStamp)


Get-ChildItem 'c:\' -Recurse | ? {$_.LastWriteTime -gt '12/14/18' -AND $_.LastWriteTime -lt '12/15/18'}