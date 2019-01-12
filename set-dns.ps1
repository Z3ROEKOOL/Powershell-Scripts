Param(
    [string]$DNS1,
    [string]$DNS2
)
Set-DnsClientServerAddress -InterfaceAlias 'Ethernet*' -ServerAddresses ($DNS1,$DNS2)