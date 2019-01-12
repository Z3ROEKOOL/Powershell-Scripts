param
(
[string]$SafeModePassword,
[string]$DomainAdminPassword,
[string]$DomainName,
[string]$DomainUser,
[string]$DomainUserPass
)
$SafeModePassword2 = (New-Object System.Management.Automation.PSCredential ('Administrator', (ConvertTo-SecureString $SafeModePassword -AsPlainText -Force)))
$DomainAdminPassword2 = (New-Object System.Management.Automation.PSCredential ('Administrator', (ConvertTo-SecureString $DomainAdminPassword -AsPlainText -Force)))
$DomainUserPassword2 = (New-Object System.Management.Automation.PSCredential ($DomainUser, (ConvertTo-SecureString $DomainUserPass -AsPlainText -Force)))
configuration InstallADForest
{
    param
    (
    [pscredential]$SafemodeAdministratorCredentials,
    [pscredential]$DomainAdminCredentials,
    [string]$DomainName,
    [pscredential]$DomainUserCred
    )

    Import-DscResource -ModuleName 'xActiveDirectory'
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'

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

        xADDomain InstallDomain
        {
            DomainName                    = $DomainName
            DomainAdministratorCredential = $DomainAdminCredentials
            SafemodeAdministratorPassword = $SafemodeAdministratorCredentials
            ForestMode                    = 'WinThreshold'
        }

        xADUser AdminUser
        {
            Ensure      = 'Present'
            UserName    = $DomainUserCred.username
            Password    = $DomainUserCred
            DomainName = $DomainName
        }

        xADGroup AddAdminToDomainAdminsGroup
        {
            GroupName = "Domain Admins"
            GroupScope = 'Global'
            Category = 'Security'
            MembersToInclude = @($DomainUserCred.username)
            Ensure = 'Present'
        }

        xADGroup MgmtUsers
        {
            GroupName = "MgmtUsers"
            GroupScope = 'Global'
            Category = 'Security'
            MembersToInclude = @($DomainUserCred.username)
            Ensure = 'Present'
        }

        xADGroup DevUsers
        {
            GroupName = "DevUsers"
            GroupScope = 'Global'
            Category = 'Security'
            MembersToInclude = @($DomainUserCred.username)
            Ensure = 'Present'
        }

        xADGroup QAUsers
        {
            GroupName = "QAUsers"
            GroupScope = 'Global'
            Category = 'Security'
            MembersToInclude = @($DomainUserCred.username)
            Ensure = 'Present'
        }

        xADGroup UATUsers
        {
            GroupName = "UATUsers"
            GroupScope = 'Global'
            Category = 'Security'
            MembersToInclude = @($DomainUserCred.username)
            Ensure = 'Present'
        }

        xADGroup PRODUsers
        {
            GroupName = "PRODUsers"
            GroupScope = 'Global'
            Category = 'Security'
            MembersToInclude = @($DomainUserCred.username)
            Ensure = 'Present'
        }

        xADGroup SFTPProdUsers
        {
            GroupName = "SFTPProdUsers"
            GroupScope = 'Global'
            Category = 'Security'
            MembersToInclude = @($DomainUserCred.username)
            Ensure = 'Present'
        }

        xADGroup SFTPNonProdUsers
        {
            GroupName = "SFTPNonProdUsers"
            GroupScope = 'Global'
            Category = 'Security'
            MembersToInclude = @($DomainUserCred.username)
            Ensure = 'Present'
        }

        xADRecycleBin ADRecycleBin
        {
            ForestFQDN = $DomainName
            EnterpriseAdministratorCredential = $DomainUserCred
            DependsOn = "[xADDomain]InstallDomain"
        }

        Script RestoreGPO            
        {                       
            GetScript = {
                $File = 'C:\cfn\gpo_test.txt'
                $Content = 'sucess'          
                $Results = @{}
                $Results['FileExists'] = Test-path $File
                $Results['ContentMatches'] = Select-String -Path $File -SimpleMatch $Content -Quiet
                $Results           
            }            
                      
            TestScript = {            
                [System.IO.File]::Exists('C:\cfn\gpo_test.txt')        
            }            
                      
            SetScript = {            
                Write-Verbose "Restoring GPO backup on"
                Copy-S3Object -BucketName arch-global-scripts -KeyPrefix active-directory/GPO  -LocalFolder c:\cfn\gpo       
                Restore-GPO -All -Domain $DomainName -Path "c:\cfn\gpo"
                "sucess" | Out-File -filepath C:\cfn\gpo_test.txt    
            }            
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

InstallADForest -ConfigurationData $ConfigData -DomainName $DomainName -SafemodeAdministratorCredentials $SafeModePassword2 -DomainAdminCredentials $DomainAdminPassword2 -DomainUserCred $DomainUserPassword2 -OutputPath C:\DSC\InstallADForest
Set-DSCLocalConfigurationManager -Path C:\DSC\InstallADForest -Verbose
Start-DscConfiguration -Wait -Force -Path C:\DSC\InstallADForest -Verbose