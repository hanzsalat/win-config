function Find-ChildItem {
    <#
    .SYNOPSIS
        Finds an item with the given name in an path
    .DESCRIPTION
        Uses Get-ChildItem and searches with Where-Object for the item
    .EXAMPLE
        Find-ChildItem -Name '...' -Path '...'
    .EXAMPLE
        Find-ChildItem '...'
    .PARAMETER Path
        default : $PWD
    .PARAMETER Name
        Is Mandatory for the function to work
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string]$Name,
        [string]$Path = $PWD
    )

    begin {}

    process {
        (Get-ChildItem -Path $Path).Where({ $_.Name -match "$Name" })
    }

    end {}
}

Set-Alias -Name fci -Value Find-ChildItem
Export-ModuleMember -Function Find-ChildItem -Alias fci