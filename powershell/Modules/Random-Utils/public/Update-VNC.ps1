function Update-VNC {
    <#
    .SYNOPSIS
        Update content of VNC Adressbook
    .DESCRIPTION
        Atm it can change the Username and scaling type of the window
    .PARAMETER path
        the path where the adress book of vnc is saved at
        default : $env:USERPROFILE\AppData\Roaming\RealVNC\VNC Address Book
    .PARAMETER username
        The name that is getting set- in for the username to login of vnc
        default : $env:USERNAME
    .PARAMETER scale
        the window scaling type, all avaible types (see link for detailts)
        default : Fit
    .PARAMETER depth
        sets the dept of Get-ChildItem for as an qol feature
        defailt : 0
    .PARAMETER current
        show the current state of Username and Scaling based on the given path plus depth
    .LINK
        https://help.realvnc.com/hc/en-us/articles/360002254618-VNC-Viewer-Parameter-Reference-
    #>
    [CmdletBinding()]
    param (
        [string]$path = ($env:APPDATA + '\RealVNC\VNC Address Book'),
        [string]$username,
        [string]$scale,
        [int]$depth = 0,
        [switch]$current,
        [switch]$select,
        [switch]$all,
        [switch]$confirm
    )

    begin {
        Import-Module PSMenu
        $patterns = @{
            A = '^(?=UserName).*$'
            B = '^(?=Scaling).*$'
            C = '^(?=Password).*$'
        }
        $replaces = @{
            A = "UserName=$username"
            B = "Scaling=$scale"
            C = "Password=$password"
        }
        if (!(Test-Path $path)) {
            Write-Warning 'Missing VNC Address books'
            break
        }
        else {
            $AddressBooks = Get-ChildItem -Path $path -Depth $depth -File *.vnc
        }
    }

    process {
        if ($current) {
            foreach ($File in $AddressBooks) {
                $obj = Get-Content -Path $File.FullName
                $ListFirstRow = ($obj -match $patterns.A).Split('=')
                $ListSecondRow = ($obj -match $patterns.B).Split('=')
                $List += @(
                    [pscustomobject]@{
                        AddressBook       = $File.BaseName
                        $ListFirstRow[0]  = $ListFirstRow[1]
                        $ListSecondRow[0] = $ListSecondRow[1]
                    }
                )
            }
            if ($List.Length -ne 0) {
                $List | Format-Table -AutoSize
            }
        }
        elseif ($select) {
            $selected = Show-Menu $AddressBooks.BaseName -MultiSelect
            if ($confirm) {
                foreach ($obj in $selected) { $Selection += $AddressBooks -match $obj }
                foreach ($Item in $Selection) {
                    if ($username.Length -gt 0) { 
                        (Get-Content -Path $Item.FullName) -replace $patterns.A, $replaces.A | Set-Content -Path $Item.FullName 
                    }
                    if ($scale.Length -gt 0) {
                        (Get-Content -Path $Item.FullName) -replace $patterns.B, $replaces.B | Set-Content -Path $Item.FullName
                    }
                }
            }
        }
        elseif ($all) {
            if ($confirm) {
                foreach ($File in $AddressBooks) {
                    if ($username.Length -gt 0) {
                        (Get-Content -Path $File.FullName) -replace $patterns.A, $replaces.A | Set-Content -Path $File.FullName 
                    }
                    if ($scale.Length -gt 0) {
                        (Get-Content -Path $File.FullName) -replace $patterns.B, $replaces.B | Set-Content -Path $File.FullName
                    }
                }
            }
        } 
        else {}
    }
}

New-Alias -Name uvnc -Value Update-VNC
Export-ModuleMember -Function Update-VNC -Alias uvnc