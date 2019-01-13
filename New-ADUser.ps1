function Test-FileExist {
    <#
    .SYNOPSIS

    .EXAMPLE
        PS>
    .PARAMETER
    .PARAMETER
    .PARAMETER
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$FirstName,

        [Parameter(Mandatory)]
        [string]$LastName,

        [Parameter(Mandatory)]
        [string]$Password,

        [Parameter()]
        [ValidateSet('Domain Users', 'Domain Admins')]
        [string]$Group,

        [Parameter()]
        [string]$Domain

    )
    process{
        try {

            $ADUserName = $FirstName[0] + $LastName
            $SecurePassword = (ConvertTo-SecureString $Password -AsPlainText -Force)

            New-ADUser -Name $ADUserName `
                -AccountPassword $SecurePassword `
                -ChangePasswordAtLogon $True `
                -GivenName $FirstName `
                -Surname $LastName

            Add-ADGroupMember -Identity $Group -Members $ADUserName
        
        } catch {
            Write-Error "$($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)"
        }
    }
}

