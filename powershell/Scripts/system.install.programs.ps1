# namespaces
    Using namespace System.IO
    Using namespace System.Collections
    Using namespace System.Management.Automation.Host

# general
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
                $install = $bucket + '/' + $thing.name
                if ($data.scoop.checked -notcontains $thing.name) {
                    if ($thing.flags -contains $data.workspace) {
                        if ($thing.flags -contains 'admin') {
                            gsudo scoop install $install
                            } 
                        else { scoop install $install }
                    }
                }
                else { 
                    Write-Host "'$( $thing.name )' is already installed" -ForegroundColor Green
                    Start-Sleep -Milliseconds 100
                    #Clear-Host
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
            if ($data.winget.checked -notcontains $item.name) {
                if ($item.flags -contains $data.workspace) {
                    gsudo winget install --id $item.name
                }
            }
            else { 
                Write-Host "'$( $item.name )' is already installed" -ForegroundColor Green
                Start-Sleep -Milliseconds 100
                #Clear-Host
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
                    [PSCustomObject]@{
                        name = '1password-cli'
                        flags = @('work','home')
                    }
                    [PSCustomObject]@{
                        name = '7zip'
                        flags = @('work','home')
                    }
                    [PSCustomObject]@{
                        name = 'btop'
                        flags = @('work','home')
                    }
                    [PSCustomObject]@{
                        name = 'chezmoi'
                        flags = @('work','home')
                    }
                    [PSCustomObject]@{
                        name = 'dark'
                        flags = @('work','home')
                    }
                    [PSCustomObject]@{
                        name = 'dotnet-sdk'
                        flags = @('work','home')
                    }
                    [PSCustomObject]@{
                        name = 'ffmpeg'
                        flags = @('work','home')
                    }
                    [PSCustomObject]@{
                        name = 'fzf'
                        flags = @('work','home')
                    }
                    [PSCustomObject]@{
                        name = 'gcc'
                        flags = @('work','home')
                    }
                    [PSCustomObject]@{
                        name = 'gdb'
                        flags = @('work','home')
                    }
                    [PSCustomObject]@{
                        name = 'gh'
                        flags = @('work','home')
                    }
                    [PSCustomObject]@{
                        name = 'git'
                        flags = @('work','home')
                    }
                    [PSCustomObject]@{
                        name = 'gsudo'
                        flags = @('work','home')
                    }
                    [PSCustomObject]@{
                        name = 'helix'
                        flags = @('work','home')
                    }
                    [PSCustomObject]@{
                        name = 'innounp'
                        flags = @('work','home')
                    }
                    [PSCustomObject]@{
                        name = 'lf'
                        flags = @('work','home')
                    }
                    [PSCustomObject]@{
                        name = 'neovim'
                        flags = @('work','home')
                    }
                    [PSCustomObject]@{
                        name = 'nircmd'
                        flags = @('work','home')
                    }
                    [PSCustomObject]@{
                        name = 'nodejs'
                        flags = @('work','home')
                    }
                    [PSCustomObject]@{
                        name = 'oh-my-posh'
                        flags = @('work','home')
                    }
                    [PSCustomObject]@{
                        name = 'pwsh'
                        flags = @('work','home')
                    }
                    [PSCustomObject]@{
                        name = 'python'
                        flags = @('work','home')
                    }
                    [PSCustomObject]@{
                        name = 'spotify-tui'
                        flags = @('work','home')
                    }
                    [PSCustomObject]@{
                        name = 'tldr'
                        flags = @('work','home')
                    }
                    [PSCustomObject]@{
                        name = 'winfetch'
                        flags = @('work','home')
                    }
                    [PSCustomObject]@{
                        name = 'yarn'
                        flags = @('work','home')
                    }
                )
                extras = @(
                    [PSCustomObject]@{
                        name = 'discord'
                        flags = @('home')
                    }
                    [PSCustomObject]@{
                        name = 'firefox'
                        flags = @('work','home')
                    }
                    [PSCustomObject]@{
                        name = 'gimp'
                        flags = @('work','home')
                    }
                    [PSCustomObject]@{
                        name = 'Keypirinha'
                        flags = @('work','home')
                    }
                    [PSCustomObject]@{
                        name = 'moonlight'
                        flags = @('work','home')
                    }
                    [PSCustomObject]@{
                        name = 'obsidian'
                        flags = @('work','home')
                    }
                    [PSCustomObject]@{
                        name = 'psreadline'
                        flags = @('work','home')
                    }
                    [PSCustomObject]@{
                        name = 'scoop-completion'
                        flags = @('work','home')
                    }
                    [PSCustomObject]@{
                        name = 'sfsu'
                        flags = @('work','home')
                    }
                    [PSCustomObject]@{
                        name = 'sharex'
                        flags = @('work','home')
                    }
                    [PSCustomObject]@{
                        name = 'spotify'
                        flags = @('work','home')
                    }
                    [PSCustomObject]@{
                        name = 'sunshine'
                        flags = @('work','home')
                    }
                    [PSCustomObject]@{
                        name = 'terminal-icons'
                        flags = @('work','home')
                    }
                    [PSCustomObject]@{
                        name = 'vcredist'
                        flags = @('work','home','admin')
                    }
                    [PSCustomObject]@{
                        name = 'vncviewer'
                        flags = @('work')
                    }
                    [PSCustomObject]@{
                        name = 'vscode'
                        flags = @('work','home')
                    }
                    [PSCustomObject]@{
                        name = 'windows-terminal'
                        flags = @('work','home')
                    }
                    [PSCustomObject]@{
                        name = 'z'
                        flags = @('work','home')
                    }
                )
                versions = @(
                    [PSCustomObject]@{
                        name = 'dotnet-nightly'
                        flags = @('work','home')
                    }
                    [PSCustomObject]@{
                        name = 'steam'
                        flags = @('home')
                    }
                    [PSCustomObject]@{
                        name = 'winget-preview'
                        flags = @('work','home')
                    }
                )
                java = @(
                    [PSCustomObject]@{
                        name = 'temurin-jdk'
                        flags = @('work','home')
                    }
                    [PSCustomObject]@{
                        name = 'temurin-lts-jdk'
                        flags =  @('work','home')
                    }
                )
                nirsoft = @(
                    [PSCustomObject]@{
                        name = 'guipropview'
                        flags = @('work','home')
                    }
                )
                nonportable = @(
                    [PSCustomObject]@{
                        name = 'equalizer-apo-np'
                        flags = @('home','admin')
                    }
                    [PSCustomObject]@{
                        name = 'nvidia-display-driver-dch-np'
                        flags = @('home','admin')
                    }
                    [PSCustomObject]@{
                        name = 'vmware-horizon-client-np'
                        flags = @('work','admin')
                    }
                )
                'nerd-fonts' = @(
                    [PSCustomObject]@{
                        name = 'Hack-NF-Mono'
                        flags = @('work','home')
                    }

                )
            }
        }
        winget = @{
            exists = & $exists -winget
            checked = & $check -winget
            list = @(
                [PSCustomObject]@{
                    name = 'AgileBits.1Password'
                    flags = @('work','home','admin')
                }
                [PSCustomObject]@{
                    name = 'PrismLauncher.PrismLauncher'
                    flags = @('home','admin')
                }
            )
        }
        workspace = $Host.UI.PromptForChoice('Workspace selection','on which workspace are you ?',@('&work','&home'),1) | ForEach-Object { if ($PSItem -eq 1) {'home'} else {'work'} }
    }

# script
    & $scoop
    & $winget
