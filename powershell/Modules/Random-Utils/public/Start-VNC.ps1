function Start-VNC {
    <#
.SYNOPSIS
    Startup script to lunch multiple vnc windows
#>
    [CmdletBinding()]
    param(
        [switch]$current,
        [switch]$confirm,
        [switch]$update,
        [switch]$single
    )

    begin {
        Import-Module PSMenu -ErrorAction Stop 
        $FilePath = $env:TEMP + '\startVNC.txt'
        $AddressBookPath = $env:APPDATA + '\RealVNC\VNC Address Book'
        if (!(Test-Path $FilePath)) {
            if (!$update) { 
                Write-Warning 'No Save file found, generate it with Start-VNC -update'
                break
            }
        }
        else {
            $File = Get-Content -Path $FilePath
        }
        if (!(Test-Path $AddressBookPath)) {
            Write-Warning 'Missing VNC Address books'
            break
        }
        else {
            $AddressBooks = Get-ChildItem -Path $AddressBookPath -Filter '*.vnc' -Depth 99
        }
    }

    process {
        if ($current) {
            Get-Content -Path $FilePath 
        }
        elseif ($update) {
            if (!(Test-Path $FilePath)) { New-Item -Path $FilePath | Out-Null }
            else {
                $selection = Show-Menu $AddressBooks.BaseName -MultiSelect
                Clear-Host
                if ($confirm) {
                    foreach ($selected in $selection) { $names += $AddressBooks -match $selected }
                    Set-Content -Path $FilePath -Value $names.FullName | Out-Null
                }
                else {
                    $selected | Format-Table -AutoSize 
                }
            }
        } 
        elseif ($single) {
            $selected = Show-Menu $AddressBooks.BaseName
            Clear-Host
            Start-Process ($AddressBooks -match $selected).FullName
        }
        else {
            foreach ($content in $File) { Start-Process -FilePath ($content) }
        }
    }
}

New-Alias -Name svnc -Value Start-VNC
Export-ModuleMember -Function Start-VNC -Alias svnc