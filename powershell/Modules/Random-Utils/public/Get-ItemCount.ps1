function Get-ItemCount {
    <#
    .SYNOPSIS
        Gets the item count of an path
    .DESCRIPTION
        Uses .count on an nested Get-ChildItem
    .EXAMPLE
        Get-ItemCount -Path '...'
    .PARAMETER Path
        default : $PWD
    #>
    [CmdletBinding()]
    param (
        [string]$Path = $pwd
    )

    begin {}

    process {
        (Get-ChildItem -Path "$Path").count
    }

    end {}
}

Set-Alias -Name gic -Value Get-ItemCount
Export-ModuleMember -Function Get-ItemCount -Alias gic