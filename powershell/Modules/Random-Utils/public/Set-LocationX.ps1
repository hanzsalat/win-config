function Set-LocationX {
    <#
    .SYNOPSIS
        Set-Location with an Menu
    #>
    param ()

    begin {}

    process {
        $obj = (Get-ChildItem -Directory).Name
        if ($null -ne $obj) {
            $dir = Show-Menu $obj
            if ($null -ne $dir) { Set-Location $dir }
        }
    }

    end{}
}

Set-Alias -Name cdx -Value Set-LocationX 
Export-ModuleMember -Function Set-LocationX -Alias cdx