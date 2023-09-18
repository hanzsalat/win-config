# general
    Using namespace System.IO
    Using namespace System.Collections
    $ErrorActionPreference = 'Stop'

# scriptblocks
    $exists = {
        param([switch]$scoop,[switch]$winget)
        if ($null -ne (Get-Command scoop -CommandType Application) -and $scoop) { $true }
        elseif ($null -ne (Get-Command winget -CommandType Application) -and $winget) { $true }
        else { $false }
    }

    $check = {
        param([switch]$scoop,[switch]$winget)
        if ($null -ne (Get-Command scoop -CommandType Application) -and $scoop) { 
            (scoop export | ConvertFrom-Json -Depth 99).apps.Name
        }
        elseif ($null -ne (Get-Command winget -CommandType Application) -and $winget) {
            $guid = [System.Guid]::NewGuid()
            $filename = $env:USERPROFILE + '\' + $guid + '.json'
            winget export -o $filename
            (Get-Content $filename | ConvertFrom-Json).Sources.packages.packageidentifier  
            Remove-Item $filename
        }
        else { $null }
    }

    $scoop = {
        if (!$data.scoop.exists) {
            Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
            Invoke-RestMethod get.scoop.sh | Invoke-Expression
        }
        $avaiabelBuckets = scoop bucket list
        foreach ($item in $data.scoop.list.GetEnumerator()) {   
            if ($avaiabelBuckets.Name -notcontains $item.key) {
                scoop bucket add $item.key
            }
            $bucket = $item.key
            foreach ($thing in $item.Value) {
                $install = $bucket + '/' + $thing
                if ($data.scoop.checked -notcontains $thing) {
                    if ($bucket -match 'nonportable') { gsudo scoop install $install } 
                    else { scoop install $install }
                }
                else { 
                    Write-Host "'$thing' is already installed" -ForegroundColor Green
                    Start-Sleep -Milliseconds 200
                    Clear-Host
                }
            }
        }
    }

    $winget = {
        if (!$data.winget.exists) {
            $avaible = $env:Path.Split(';') | Where-Object {$PSItem -match 'WindowsApps'}
            if ($null -eq $avaible) {
                Write-Host 'missing winget but how ?' -ForegroundColor DarkYellow
                [void](setx Path "$env:Path;C:\Users\simon\AppData\Local\Microsoft\WindowsApps")
                Write-Host 'fixed environmental variable path to include the windowsapps' -ForegroundColor Cyan
            }
        }
        foreach ($item in $data.winget.list) {
            if ($data.winget.checked -notcontains $item) {
                winget install --id $item
            }
            else { 
                Write-Host "'$item' is already installed" -ForegroundColor Green
                Start-Sleep -Milliseconds 200
                Clear-Host
            }
        }
    }

# data
    $data = @{
        scoop = @{
            exists = & $exists -scoop
            checked = & $check -scoop
            list = [ordered]@{
                main = @(
                    '1password-cli'
                    '7zip'
                    'bottom'
                    'dark'
                    'dotnet-sdk'
                    'gcc'
                    'gdb'
                    'gh'
                    'git'
                    'gsudo'
                    'innounp'
                    'neovim'
                    'nircmd'
                    'nodejs'
                    'oh-my-posh'
                    'pwsh'
                    'python'
                    'spotify-tui'
                    'winfetch'
                    'yarn'
                    'fzf'
                )
                extras = @(
                    'discord'
                    'firefox'
                    'gimp'
                    'powertoys'
                    'psreadline'
                    'scoop-completion'
                    'sfsu'
                    'spotify'
                    'terminal-icons'
                    'vcredist2022'
                    'vscode'
                    'windows-terminal'
                    'z'
                )
                versions = @(
                    'dotnet-nightly'
                    'steam'
                    'winget-preview'
                )
                java = @(
                    'temurin-jdk'
                    'temurin-lts-jdk'
                )
                nirsoft = @(
                    'winlister'
                )
                nonportable = @(
                    'equalizer-apo-np'
                    'nvidia-display-driver-dch-np'
                )
            }
        }
        winget = @{
            exists = & $exists -winget
            checked = & $check -winget
            list = @(
                'AgileBits.1Password'
            )
        }
    }

# script
    & $scoop
    & $winget