# generals
    Using namespace System
    Using namespace System.Drawing.Text
    $ErrorActionPreference = 'Stop'

# functions/scriptblocks/classes
    function New-Shortcut {
        param(
            [parameter(Mandatory)]
            [string]$name,
            [parameter(Mandatory)]
            [string]$target,
            [parameter(Mandatory)]
            [string]$arguments,
            [parameter(Mandatory)]
            [string]$path
        )

        process {
            $WshShell = New-Object -comObject WScript.Shell
            $shortcut = $WshShell.CreateShortcut("$path\$name.lnk")
            $shortcut.TargetPath = $target
            $shortcut.Arguments = $arguments
            $shortcut.Save()
        }
    }

    function New-Junction {
        param(
            [string]
            $path,
            $junction
        )
            
        begin {
            $guid = [guid]::newguid()
            $tmp = "$env:TMP\$guid"
        }

        process {
            if (!(Test-Path -Path $junction)) {
                New-Item -ItemType Junction -Path $junction -Target $path
            }
            elseif ((Get-Item $junction).Attributes -notmatch 'ReparsePoint') {
                New-Item -ItemType Directory -Path $tmp
                Get-ChildItem -Path $junction | Copy-Item -Destination $tmp -Recurse -Container
                Remove-Item $junction -Recurse -Force
                New-Item -ItemType Junction -Path $junction -Target $path
                Get-ChildItem -Path $tmp | Copy-Item -Destination $junction -Recurse -Container
                Remove-Item $tmp -Recurse -Force
            }
        }
    }

    $setEnvVariables = {
        if ($script.data.checked.Scoop) {
            [void](setx SCOOP_ROOT (Get-Item $script.paths.shims).parent.FullName)
        }
        else {
            Write-Error "missing scoop on the system! for help use the readme file"
        }
    }

    $getuserchoice = {

    }

    $git = {

    }

    $windowmanager = {
        if ($script.data.checked.GlazeWM -and $script.data.userchoice.glaewm) {
            if (Test-Path ($script.paths.startup + '\komorebi.lnk')) {
                Remove-Item ($script.paths.startup + '\komorebi.lnk')
            }
        
            if (!(Test-Path ($script.paths.config + '\glazewm'))) {
                New-Item ($script.paths.config + '\glazewm') -ItemType Directory
            }
        
            $copy = @{
                Path        = $PSScriptRoot + "\.config\glazewm\$($script.data.userchoice.workspace).yaml"
                Destination = $script.paths.config + '\glazewm\config.yaml'
            }
            Copy-Item @copy -Recurse -Force
        
            $shortcut = @{
                name      = 'glazewm'
                target    = "glazewm.exe"
                arguments = "--config=$($script.paths.config)\glazewm\config.yaml"
                path      = $script.paths.startup
            }
            New-Shortcut @shortcut
        
            Get-Process komorebi -ErrorAction Ignore | Stop-Process
            Get-Process whkd -ErrorAction Ignore | Stop-Process
            if (!(Get-Process glazewm -ErrorAction Ignore)) {
                Start-Process powershell -ArgumentList "glazewm --config=$($script.paths.config)\glazewm\config.yaml" -WindowStyle Hidden
            }
        }
        else {
            Write-Error "missing GlazeWM on the system! for help use the readme file"
        }

        if ($script.data.checked.Komorebi -and $script.data.checked.whkd -and $script.data.userchoice.komorebi) {
            if (Test-Path ($script.paths.startup + '\glazewm.lnk')) {
                Remove-Item ($script.paths.startup + '\glazewm.lnk')
            }
                    
            if (!(Test-Path ($script.paths.config + '\komorebi'))) {
                New-Item ($script.paths.config + '\komorebi') -ItemType Directory
            }

            if (!(Test-Path ($script.paths.config + '\whkd'))) {
                New-Item ($script.paths.config + '\whkd') -ItemType Directory
            }
        
            $copy = @{
                Path        = $PSScriptRoot + '\.config\komorebi'
                Destination = $script.paths.config + '\komorebi'
            }
            Copy-Item @copy -Recurse -Force

            $copy = @{
                Path        = $PSScriptRoot + '\.config\whkd\whkdrc'
                Destination = $script.paths.config
            }
            Copy-Item @copy -Recurse -Force
        
            $shortcut = @{
                name      = 'komorebi'
                target    = "powershell.exe"
                arguments = 'komorebic start -c $env:USERPROFILE/.config/komorebi/komorebi.json --whkd'
                path      = $script.paths.startup
            }
            New-Shortcut @shortcut

            [void](setx KOMOREBI_CONFIG_HOME ($script.paths.config + '\komorebi'))
            [void](setx WHKD_CONFIG_HOME ($script.paths.config + '\whkd'))
            
            Get-Process glazewm -ErrorAction Ignore | Stop-Process
            
            if (!(Get-Process komorebi -ErrorAction Ignore)) {
                Start-Process -FilePath ($script.paths.startup + '\komorebi.lnk')
            }
            else {
                Write-Error "missing Komorebi or whkd on system! for help use the readme file"
            }
        }
    }

    $taskbar = {
        if ($script.data.checked.Nircmd) {
            $shortcut = @{
                name      = 'nircmd'
                target    = (Get-Command nircmd).Path
                arguments = 'win trans class Shell_TrayWnd 256'
                path      = $script.paths.startup
            }
            New-Shortcut @shortcut
            Invoke-Item ($script.paths.startup + '\nircmd.lnk')
        }
        else {
            Write-Error "missing nircmd on the system! for help use the readme file"
        }
        
    }

    $powershell = {
        if (!(Test-Path ($script.paths.documents + '\WindowsPowerShell'))) {
            New-Item ($script.paths.documents + '\WindowsPowerShell') -ItemType Directory
        }

        if (!(Test-Path ($script.paths.documents + '\PowerShell'))) {
            New-Item ($script.paths.documents + '\PowerShell') -ItemType Directory
        }

        if (!(Test-Path ($script.paths.config+ '\powershell'))) {
            New-Item ($script.paths.config + '\powershell') -ItemType Directory
        }

        $junction = @{
            junction = $script.paths.documents + '\WindowsPowerShell'
            path     = $script.paths.documents + '\PowerShell'
        }
        New-Junction @junction

        $copy = @{
            Path        = $PSScriptRoot + '\powershell'
            Destination = $script.paths.documents + '\PowerShell'
        }
        Copy-Item @copy -Recurse -Force
    }

    $packages = {
        foreach ($item in $script.data.avaible) {
            switch ($item) {
                nvim {
                    if ($script.data.checked.Neovim) {
                        if (!(Test-Path ($script.paths.config + '\nvim'))) {
                            New-Item ($script.paths.config + '\nvim') -ItemType Directory
                        }

                        $junction = @{
                            junction = $env:LOCALAPPDATA + '\nvim'
                            path     = $script.paths.config + '\nvim'
                        }
                        New-Junction @junction 

                        $copy = @{
                            Path        = $PSScriptRoot + '\.config\nvim'
                            Destination = $script.paths.config + '\nvim'
                        }
                        Copy-Item @copy -Recurse -Force 
                    }
                    else {
                        Write-Error "missing neovim on the system! for help use the readme file"
                    }
                }
                spt {
                    if ($script.data.checked.SpotifyTui) {
                        if (!(Test-Path ($script.paths.config + '\spotify-tui'))) {
                            New-Item ($script.paths.config + '\spotify-tui') -ItemType Directory
                        }
        
                        $copy = @{
                            Path        = $PSScriptRoot + '\.config\spotify-tui'
                            Destination = $script.paths.config + '\spotify-tui'
                        }
                        Copy-Item @copy -Recurse -Force
                    }
                    else {
                        Write-Error "missing spotify-tui on system! for help use the readme file"
                    }
                }
                winfetch {
                    if ($script.data.checked.Winfetch) {
                        if (!(Test-Path ($script.paths.config + '\winfetch'))) {
                            New-Item ($script.paths.config + '\winfetch') -ItemType Directory
                        }
        
                        $copy = @{
                            Path        = $PSScriptRoot + '\.config\winfetch'
                            Destination = $script.paths.config + '\winfetch'
                        }
                        Copy-Item @copy -Recurse -Force
                    }
                    else {
                        Write-Error "missing winfetch on system! for help use the readme file"
                    }
                }
                terminal {
                    if ($script.data.checked.Terminal) {
                        if (!(Test-Path ($script.paths.config + '\terminal'))) {
                            New-Item ($script.paths.config + '\terminal') -ItemType Directory
                        }
                        
                        $junction = @{
                            junction = $env:SCOOP_ROOT + '\persist\windows-terminal\settings'
                            path     = $script.paths.config + '\terminal'
                        }
                        New-Junction @junction

                        $copy = @{
                            Path        = $PSScriptRoot + '\.config\terminal'
                            Destination = $script.paths.config + '\terminal'
                        }
                        Copy-Item @copy -Recurse -Force
                    }
                    else {
                        Write-Error "missing terminal on system! for help use the readme file"
                    }
                }
                helix {
                    if ($script.data.checked.Helix) {
                        if (!(Test-Path ($script.paths.config + '\helix'))) {
                            New-Item ($script.paths.config + '\helix') -ItemType Directory
                        }

                        $junction = @{
                            junction = $env:APPDATA + '\helix'
                            path     = $script.paths.config + '\helix'
                        }
                        New-Junction @junction

                        $copy = @{
                            Path        = $PSScriptRoot + '\.config\helix'
                            Destination = $script.paths.config + '\helix'
                        }
                        Copy-Item @copy -Recurse -Force
                    }
                    else {
                        Write-Error "missing helix on system! for help use the readme file"
                    }
                }
            }
        }
    }

    $prompt = {
        if ($script.data.checked.Posh -and $script.data.userchoice.posh) {
            $script.data.userconfig.prompt.posh = $true 
        }

        if ($script.data.checked.Starship -and $script.data.userchoice.starship) {
            $script.data.userconfig.prompt.starship = $true   
        }
    }

    $userconfig = {
        $item = @{
            Path  = "$($script.paths.config)\powershell\userconfig.json"
            Value = $script.data.userconfig | ConvertTo-Json
        }
        $null = New-Item @item -Force
    }

# data and varialbe sets
    $script = @{
        PATH = @{
            STATUP      = [Environment]::GetFolderPath(7)
            DOCS        = [Environment]::GetFolderPath(5)
            USER_CONFIG = "$env:USERPROFILE\.config"
            SCOOP_SHIMS = $env:Path.Split(';') | Where-Object { $_ -match 'shims' }
            REPO_TMP    = "$env:TMP\win-config"
            REPO_ROOT   = (Get-Item $PSScriptRoot).Parent.Parent.ResolvedTarget
        }
        DATA = @{
            manifest   = & $PSScriptRoot\..\..\.config\manifest.ps1
            checked    = & $PSScriptRoot\powershell.checks.ps1
            userconfig = @{
                prompt = @{
                    posh      = $null
                    starship  = $null
                    themePath = "$($script.PATH.DOCS)\PowerShell\Themes" 
                }
            }
        }
    }

# script itself
    <#
    & $setEnvVariables
    & $getuserchoice
    & $git
    & $windowmanager
    & $taskbar
    & $powershell
    & $packages
    & $prompt
    & $userconfig
    & $Profile.CurrentUserAllHosts
    #>
    $script
