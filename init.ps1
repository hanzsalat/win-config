# generals
    Using namespace System
    Using namespace System.Drawing.Text
    $ErrorActionPreference = 'Stop'

# functions/scriptblocks/classes
    function Test-Config {
        [CmdletBinding()]
        [OutputType([psobject])]
        param (
            [parameter(Mandatory, ValueFromPipeline, Position = 1)]
            [string]$config
        )
            
        begin {
            $validationSet = @{
                workspace     = @('home', 'work')
                windowmanager = @('glazewm', 'komorebi')
                prompt        = @('omp', 'starship')
                taskbar       = 'Boolean'
                packages      = @('winfetch', 'terminal', 'spt', 'pwsh', 'nvim')
            }
        }

        process {
            try {
                $null = Test-Path $config
                $content = . $config
                $compare = Compare-Object $validationSet.Keys $content.Keys -IncludeEqual
                if ($compare.SideIndicator -notmatch '==') {
                    Write-Error "wrong or missing option in config file"
                }
                foreach ($item in $content.GetEnumerator()) {
                    switch ($item.Key) {
                        taskbar {
                            if ($item.Value.GetType().Name -notmatch $validationSet[ $item.Key ]) {
                                Write-Error "not correct value '$( $item.Value)' for option '$( $item.Key )'"
                            }
                        }
                        packages { 
                            foreach ($thing in $item.Value) {
                                if ($thing -notin $validationSet[ $item.Key ]) {
                                    Write-Error "not included package '$thing'"
                                }
                            }
                        }
                        default { 
                            if ($item.Value -notin $validationSet[ $item.Key ] ) {
                                Write-Error "not correct value '$( $item.Value)' for option '$( $item.Key )'"
                            }
                        }
                    }
                }
                $content
            }
            catch {
                Write-Error $PSItem
            }
        }
    }
    function New-Shortcut {
        param(
            [string]
            $name,
            $target,
            $arguments,
            $path
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

    $scoop = {
        if (!$script.data.checked.Scoop) {
            Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
            Invoke-RestMethod get.scoop.sh | Invoke-Expression
            scoop install main/git
            $script.data.checked = & $PSScriptRoot\powershell\Scripts\powershell.check.ps1
        }
        $bucketlist = scoop bucket list
        $diff = Compare-Object -ReferenceObject $script.data.buckets -DifferenceObject $bucketlist.name | 
        Where-Object { $_.SideIndicator -eq '<=' } | 
        Select-Object InputObject
        foreach ($item in $diff) {
            scoop bucket add $item.InputObject
        }
        [void](setx SCOOP_ROOT (Get-Item $script.paths.shims).parent.FullName)
    }
    $windowmanager = {
        if (!$script.data.checked.GlazeWM -and $script.data.config.windowmanager -eq 'glazewm') {
            scoop install extras/glazewm
            $script.data.checked = & $PSScriptRoot\powershell\Scripts\powershell.check.ps1
        }

        if (!$script.data.checked.Komorebi -and $script.data.config.windowmanager -eq 'komorebi') {
            scoop install extras/komorebi
            scoop install extras/whkd
            $script.data.checked = & $PSScriptRoot\powershell\Scripts\powershell.check.ps1
        }

        if ($script.data.checked.GlazeWM -and $script.data.config.windowmanager -eq 'glazewm') {
            if (Test-Path ($script.paths.startup + '\komorebi.lnk')) {
                Remove-Item ($script.paths.startup + '\komorebi.lnk')
            }
        
            if (!(Test-Path ($script.paths.config + '\glazewm'))) {
                New-Item ($script.paths.config + '\glazewm') -ItemType Directory
            }
        
            $copy = @{
                Path        = "$PSScriptRoot\.config\glazewm\$($script.data.config.workspace).yaml"
                Destination = "$($script.paths.config)\glazewm\config.yaml"
            }
            Copy-Item @copy -Recurse -Force
        
            $shortcut = @{
                name      = 'glazewm'
                target    = "powershell.exe"
                arguments = "glazewm --config=$($script.paths.config)\glazewm\config.yaml"
                path      = $script.paths.startup
            }
            New-Shortcut @shortcut
        
            Get-Process komorebi -ErrorAction Ignore | Stop-Process
            Get-Process whkd -ErrorAction Ignore | Stop-Process
            if (!(Get-Process glazewm -ErrorAction Ignore)) {
                Start-Process -FilePath ($script.paths.startup + '\glazewm.lnk')
            }
        }

        if ($script.data.checked.Komorebi -and $script.data.config.windowmanager -eq 'komorebi') {
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
                Path        = $PSScriptRoot + '\.config\komorebi\*'
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
                arguments = 'komorebic start -c $Env:USERPROFILE/.config/komorebi/komorebi.json --whkd'
                path      = $script.paths.startup
            }
            New-Shortcut @shortcut

            [void](setx KOMOREBI_CONFIG_HOME ($script.paths.config + '\komorebi'))
            [void](setx WHKD_CONFIG_HOME ($script.paths.config + '\whkd'))
            
            Get-Process glazewm -ErrorAction Ignore | Stop-Process
            if (!(Get-Process komorebi -ErrorAction Ignore)) {
                Start-Process -FilePath ($script.paths.startup + '\komorebi.lnk')
            }
        }
    }
    $taskbar = {
        if (!$script.data.checked.Nircmd -and $script.data.config.taskbar) {
            scoop install main/nircmd
            $script.data.checked = & $PSScriptRoot\powershell\Scripts\powershell.check.ps1
        }

        if ($script.data.checked.Nircmd -and $script.data.config.taskbar) {
            $shortcut = @{
                name      = 'nircmd'
                target    = (Get-Command nircmd).Path
                arguments = 'win trans class Shell_TrayWnd 255'
                path      = $script.paths.startup
            }
            New-Shortcut @shortcut
        } 

        if ($script.data.checked.Nircmd -and !$script.data.config.taskbar) {
            $shortcut = @{
                name      = 'nircmd'
                target    = (Get-Command nircmd).Path
                arguments = 'win trans class Shell_TrayWnd 256'
                path      = $script.paths.startup
            }
            New-Shortcut @shortcut
        } 

        Invoke-Item ($script.paths.startup + '\nircmd.lnk') -ErrorAction Ignore
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

        $copy = @{
            Path        = $PSScriptRoot + '\.config\powershell\*'
            Destination = $script.paths.config + '\powershell'
        }
        Copy-Item @copy -Recurse -Force

        $junction = @{
            junction = $script.paths.documents + '\PowerShell'
            path     = $script.paths.config + '\powershell'
        }
        New-Junction @junction

        $junction = @{
            junction = $script.paths.documents + '\WindowsPowerShell'
            path     = $script.paths.config + '\powershell'
        }
        New-Junction @junction

        if ($script.data.modules -notcontains 'z') {
            scoop install extras/z
        }

        if ($script.data.modules -notcontains 'terminal-icons') {
            scoop install extras/terminal-icons
        }

        if ($script.data.modules -notcontains 'psreadline') {
            scoop install extras/psreadline
        }
    }
    $prompt = {
        if (!$script.data.checked.Posh -and $script.data.config.prompt -eq 'omp') {
            scoop install main/oh-my-posh
            $script.data.checked = & $PSScriptRoot\powershell\Scripts\powershell.check.ps1
        }

        if (!$script.data.checked.Starship -and $script.data.config.prompt -eq 'starship') {
            scoop install main/starship
            $script.data.checked = & $PSScriptRoot\powershell\Scripts\powershell.check.ps1
        }

        if ($script.data.checked.Posh -and $script.data.config.prompt -eq 'omp') {
            $script.data.userconfig = @{
                prompt = @{
                    omp      = $true
                    starship = $false
                }
            }
        }

        if ($script.data.checked.Starship -and $script.data.config.prompt -eq 'starship') {
            $script.data.userconfig = @{
                prompt = @{
                    omp      = $false
                    starship = $true
                }
            }
        }

        if ($script.data.fonts -notcontains 'Hack Nerd Font Mono') {
            scoop install nerd-fonts/Hack-NF-Mono
            $script.data.checked = & $PSScriptRoot\powershell\Scripts\powershell.check.ps1
        }
    }
    $packages = {
        foreach ($item in $script.data.config.packages) {
            switch ($item) {
                nvim {
                    if (!$script.data.checked.Neovim) {
                        scoop install main/neovim
                        $script.data.checked = & $PSScriptRoot\powershell\Scripts\powershell.check.ps1
                    }

                    if (!(Test-Path ($script.paths.config + '\nvim'))) {
                        New-Item ($script.paths.config + '\nvim') -ItemType Directory
                    }
        
                    $copy = @{
                        Path        = $PSScriptRoot + '\.config\nvim\*'
                        Destination = $script.paths.config + '\nvim'
                    }
                    Copy-Item @copy -Recurse -Force
        
                    $junction = @{
                        junction = $env:LOCALAPPDATA + '\nvim'
                        path     = $script.paths.config + '\nvim'
                    }
                    New-Junction @junction  
                }
                spt {
                    if (!$script.data.checked.SpotifyTui) {
                        scoop install main/spotify-tui
                        $script.data.checked = & $PSScriptRoot\powershell\Scripts\powershell.check.ps1
                    }

                    if (!(Test-Path ($script.paths.config + '\spotify-tui'))) {
                        New-Item ($script.paths.config + '\spotify-tui') -ItemType Directory
                    }
        
                    $copy = @{
                        Path        = $PSScriptRoot + '\.config\spotify-tui\*'
                        Destination = $script.paths.config + '\spotify-tui'
                    }
                    Copy-Item @copy -Recurse -Force
                }
                winfetch {
                    if (!$script.data.checked.Winfetch) {
                        scoop install main/winfetch
                        $script.data.checked = & $PSScriptRoot\powershell\Scripts\powershell.check.ps1
                    }

                    if (!(Test-Path ($script.paths.config + '\winfetch'))) {
                        New-Item ($script.paths.config + '\winfetch') -ItemType Directory
                    }
        
                    $copy = @{
                        Path        = $PSScriptRoot + '\.config\winfetch\*'
                        Destination = $script.paths.config + '\winfetch'
                    }
                    Copy-Item @copy -Recurse -Force
                }
                terminal {
                    if (!$script.data.checked.Terminal) {
                        scoop install extras/windows-terminal
                        $script.data.checked = & $PSScriptRoot\powershell\Scripts\powershell.check.ps1
                    }

                    if (!(Test-Path ($script.paths.config + '\terminal'))) {
                        New-Item ($script.paths.config + '\terminal') -ItemType Directory
                    }
        
                    $copy = @{
                        Path        = $PSScriptRoot + '\.config\terminal\*'
                        Destination = $script.paths.config + '\terminal'
                    }
                    Copy-Item @copy -Recurse -Force
        
                    $junction = @{
                        junction = $env:SCOOP_ROOT + '\persist\windows-terminal\settings'
                        path     = $script.paths.config + '\terminal'
                    }
                    New-Junction @junction
                }
                helix {
                    if (!$script.data.checked.Helix) {
                        scoop install main/helix
                        $script.data.checked = & $PSScriptRoot\powershell\Scripts\powershell.check.ps1
                    }
                        
                    if (!(Test-Path ($script.paths.config + '\helix'))) {
                        New-Item ($script.paths.config + '\helix') -ItemType Directory
                    }
        
                    $copy = @{
                        Path        = $PSScriptRoot + '\.config\helix\*'
                        Destination = $script.paths.config + '\helix'
                    }
                    Copy-Item @copy -Recurse -Force
        
                    $junction = @{
                        junction = $env:APPDATA + '\helix'
                        path     = $script.paths.config + '\helix'
                    }
                    New-Junction @junction
                }
                pwsh {
                    if (!$script.data.checked.Pwsh) {
                        scoop install main/pwsh
                        $script.data.checked = & $PSScriptRoot\powershell\Scripts\powershell.check.ps1
                    }
                }
            }
        }
    }
    $userconfig = {
        $item = @{
            Path  = $script.paths.documents + '\WindowsPowerShell\userconfig.json'
            Value = $script.data.userconfig | ConvertTo-Json
        }
        $null = New-Item @item -Force
    }

# data and varialbe sets
    $script = @{
        paths = @{
            startup   = [Environment]::GetFolderPath(7)
            documents = [Environment]::GetFolderPath(5)
            config    = $env:USERPROFILE + '\.config'
            shims     = $env:Path.Split(';') | Where-Object { $_ -match 'shims' }
        }
        data  = @{
            config     = $PSScriptRoot + '\config.ps1' | Test-Config
            avaible    = (Get-ChildItem $PSScriptRoot\.config).BaseName
            checked    = & $PSScriptRoot\.config\powershell\Scripts\powershell.check.ps1
            userconfig = New-Object -TypeName hashtable
            buckets    = @('extras', 'main', 'nonportable', 'versions', 'nerd-fonts')
            modules    = (Get-Module -ListAvailable).Name
            fonts      = (New-Object InstalledFontCollection).Families
        }
    }

# script itself
    & $scoop
    & $windowmanager
    & $taskbar
    & $powershell
    & $prompt
    & $packages
    & $userconfig
    & $Profile.CurrentUserAllHosts