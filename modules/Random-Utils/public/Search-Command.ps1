function Search-Command {
    <#
    .SYNOPSIS
        Searching for avaible commands
    .DESCRIPTION
        Uses Get-Command and searches with Where-Object for avaible commands with the given name
        or use the -Source switch to serach for sources to get all avaible Commands it
    .EXAMPLE
        Search-Command -Name '...'
    .EXAMPLE
        Search-Command '...' -Source
    .PARAMETER Name
        The Name wich is used to search for the command
    .PARAMETER Source
        Switch to search for commands of an source
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][String]$Name,
        [switch]$Source
    )

    begin {}

    process {
        if ($Source) { (Get-Command).Where({ $_.Source -match $Name }) }
        else { (Get-Command).Where({ $_.Name -match $Name }) }
    }

    end {}
}

Set-Alias -Name scmd -Value Search-Command
Export-ModuleMember -Function Search-Command -Alias scmd