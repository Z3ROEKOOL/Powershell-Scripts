param
(
[string]$DomainDNSName,
[string]$DomainNetBios,
[string]$DomainUserName,
[string]$DomainUserPass,
[string]$RestoreModePassword
)
$name ="$DomainNetBios\$DomainUserName"
$DomainUserCred = (New-Object System.Management.Automation.PSCredential ($name, (ConvertTo-SecureString $DomainUserPass -AsPlainText -Force)))
$SafeModePassword2 = (New-Object System.Management.Automation.PSCredential ('Administrator', (ConvertTo-SecureString $RestoreModePassword -AsPlainText -Force)))
configuration JoinADForest
{
    param
    (
    [string]$DomainDNSName,
    [pscredential]$DomainUserCreds,
    [pscredential]$RestoreModePassword
    )

    Import-DscResource -ModuleName 'xActiveDirectory'
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'
    Import-DscResource -ModuleName 'ComputerManagementDsc'

    Node $AllNodes.NodeName {
                    
        LocalConfigurationManager
        {
            ActionAfterReboot = 'ContinueConfiguration'
            ConfigurationMode = 'ApplyOnly'
            RebootNodeIfNeeded = $true
        }

        WindowsFeature ADDSInstall 
        {
            Ensure = 'Present'
            Name = 'AD-Domain-Services'
        }

        WindowsFeature RSAT
        {
            Ensure = "Present"
            Name = "RSAT-ADDS"
        }

        WindowsFeature RSAT-AD-PS
        {
            Name   = 'RSAT-AD-PowerShell'
            Ensure = 'Present'
        }

        Computer JoinDomain
        {
            Name = ($Env:Computername)
            DomainName = $DomainDNSName
            Credential = $DomainUserCreds
        }

        xADDomainController SecondDC 
        { 
            DomainName = $DomainDNSName
            SafemodeAdministratorPassword = $RestoreModePassword
            DomainAdministratorCredential = $DomainUserCreds
        }

        
    }
}
$ConfigData = @{
    AllNodes = @(
        @{
            NodeName                        = 'localhost'
            PSDscAllowPlainTextPassword     = $true
            PSDscAllowDomainUser            = $true
        }
    )  
}
JoinADForest -ConfigurationData $ConfigData -DomainDNSName $DomainDNSName -DomainUserCreds $DomainUserCred -RestoreModePassword $SafeModePassword2 -OutputPath C:\DSC\JoinADForest
Set-DSCLocalConfigurationManager -Path C:\DSC\JoinADForest -Verbose
Start-DscConfiguration -Wait -Force -Path C:\DSC\JoinADForest -Verbose