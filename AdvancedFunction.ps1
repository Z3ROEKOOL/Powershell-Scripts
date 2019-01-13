function New-AdvancedFunction {
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
    
    )
    process{
        try {
        
        } catch {
            Write-Error "$($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)"
        }
    }
}