# default error handling
    $ErrorActionPreference = 'Stop'

# function and script blocks
    function Test-Config {
        param (
            $config = $(Get-ChildItem -Path $PSScriptRoot\config.ps1)
        )
        
        process {
            $content = . $config
            foreach ($item in $content.GetEnumerator()) {
                switch ($item.name) {
                    workspace {
                        if ($item.value -notmatch 'home|work') {
                            Write-Error "No valid value for $($item.name) [$($item.value)]"
                        }
                    }
                    windowmanager {
                        if ($item.value -notmatch 'glazewm|komorebi') {
                            Write-Error "No valid value for $($item.name) [$($item.value)]"
                        }
                    }
                    prompt {
                        if ($item.value -notmatch 'omp|starship') {
                            Write-Error "No valid value for $($item.name) [$($item.value)]"
                        }
                    }
                    taskbar {
                        if ($item.value.GetType().name -ne 'boolean') {
                            Write-Error "No valid type for $($item.name) [$($item.value)]"
                        }
                    }
                    packages {
                        if ($item.value.GetType().BaseType.name -ne 'Array') {
                            Write-Error "Wrong type of packages $($item.value.GetType().BaseType.name)"
                        } else {
                            foreach ($item in $item.value) {
                                if ($item -notmatch 'glazewm|nvim|winfetch|spt|terminal') {
                                    Write-Error "Not included package $item"
                                }
                            }
                        }
                    }
                    default {
                        Write-Error "Missing\Wrong option in config [$($item.name)]"
                    }
                }
            }
        }
        
        end {
            return $content
        }
    }
    function New-Shortcut {
        param(
            [string]
            # Specifies the file name
            $name,
            # Spcifies the target of the shortcut
            $target,
            # add arguments if needed
            $arguments,
            # path to where the shortcut should be generated, default use startup dir
            $path = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
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
            # original path of the directory
            $path,
            # target path of the junction
            $target
        )
        
        process {
            $guid = [guid]::newguid()
            $tmp = "$env:TEMP\$guid"
            if (!(Test-Path -Path $path)) {
                $null = New-Item -ItemType Junction -Path $path -Target $target
            } 
            elseif ($((Get-Item $path).Attributes) -notmatch 'ReparsePoint') {
                $null = New-Item -ItemType Directory -Path $tmp
                $items = Get-ChildItem -Path $path
                foreach ($item in $items) {
                    Move-Item -Path $item -Destination $tmp
                }
                $null = New-Item -ItemType Junction -Path $path -Target $target
                foreach ($item in $items) {
                    Move-Item -Path $tmp\$($item.Name) -Destination $target
                }
                Remove-Item -Path $tmp -Recurse -Force
            }
        }
    }

# get config content and validate it
    $config = Test-Config

# check for installed software
    $checked = & $PSScriptRoot\powershell\Scripts\powershell.check.ps1

# startup path
    $startupPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"

# take actions on stuff in the config file
# windowmanager
# glazewm
# .Link
# https://github.com/lars-berger/GlazeWM 
    if ($checked.GlazeWM) {
        # check for komorebi shortcut and delete it
            if (Test-Path "$startupPath\komorebi.lnk") {
                Remove-Item -Path "$startupPath\komorebi.lnk"
            }
        # add glazewm to $shortcuts
            $shortcut = @{
                name = 'glazewm'
                target = "powershell.exe"
                arguments = "-WindowStyle hidden -Command glazewm --config=$env:USERPROFILE\.config\glaze-wm\config.yaml"
            }
            New-Shortcut @shortcut
        # copy .config files
            if (!(Test-Path $env:USERPROFILE\.config\glaze-wm)) {
                $null = New-Item $env:USERPROFILE\.config\glaze-wm -ItemType Directory
            }
            $copy = @{
                Path = "$PSScriptRoot\.config\glaze-wm\$($config.workspace).yaml"
                Destination = "$env:USERPROFILE\.config\glaze-wm\config.yaml"
            }
            Copy-Item @copy -Recurse -Force
        # reload glazewm
            Get-Process glazewm | Stop-Process
            Invoke-Item $startupPath\glazewm.lnk
    }
# komorebi
    elseif ($checked.Komorebi) {
        # check for glazewm shortcut and delete it
            if (Test-Path "$startupPath\glazewm.lnk") {
                Remove-Item -Path "$startupPath\glazewm.lnk"
            }
        # add komorebi to $shortcuts
            $shortcut = @{
                name = 'komorebi'
                target = "powershell.exe"
                arguments = '-WindowStyle hidden -Command komorebic start --await-configuration'
            }
            New-Shortcut @shortcut
        # copy .config files
            if (!(Test-Path $env:USERPROFILE\.config\komorebi)) {
                $null = New-Item $env:USERPROFILE\.config\komorebi -ItemType Directory
            }
            $copy = @{
                Path = "$PSScriptRoot\.config\komorebi\*"
                Destination = "$env:USERPROFILE\.config\komorebi"
            }
            Copy-Item @copy -Recurse -Force
    }
# error handling
    else {
        if (!$checked.Komorebi) {
            Write-Error 'Missing Komorebi'
        }
        if (!$checked.GlazeWM) {
            Write-Error 'Missing Glaze-WM'
        }
    }

# taskbar
# show taskbar
    if ($config.taskbar -and $checked.Nircmd) {
        $shortcut = @{
            name = 'nircmd'
            target = (Get-Command nircmd).Path
            arguments = 'win trans class Shell_TrayWnd 255'
        }
        New-Shortcut @shortcut
        Invoke-Item $startupPath\nircmd.lnk
    }
# remove taskbar
    elseif (!$config.taskbar -and $checked.Nircmd) {
        $shortcut = @{
            name = 'nircmd'
            target = (Get-Command nircmd).Path
            arguments = 'win trans class Shell_TrayWnd 256'
        }
        New-Shortcut @shortcut
        Invoke-Item $startupPath\nircmd.lnk
    }
# error handling
    else {
        if (!$checked.Nircmd) {
            Write-Error 'Missing Nircmd'
        }
    }


# powershell + terminal
    $junction = @{
        path = "$env:USERPROFILE\Documents\WindowsPowerShell"
        target = "$env:USERPROFILE\Documents\PowerShell"
    }
    New-Junction @junction
    if (!(Test-Path $env:USERPROFILE\Documents\PowerShell)) {
        $null = New-Item $env:USERPROFILE\Documents\PowerShell -ItemType Directory
    }
    $copy = @{
        Path = "$PSScriptRoot\powershell\*"
        Destination = "$env:USERPROFILE\Documents\PowerShell"
    }
    Copy-Item @copy -Recurse -Force
# oh-my-posh
    if ($config.prompt -eq 'omp' -and $checked.Posh) {
        $null = New-Item -Path $env:USERPROFILE\Documents\PowerShell\userconfig.ps1 -Value "@{Prompt=1}" -Force
    }
# starship
    elseif ($config.prompt -eq 'starship' -and $checked.Starship) {
        $null = New-Item -Path $env:USERPROFILE\Documents\PowerShell\userconfig.ps1 -Value "@{Prompt=2}" -Force
    }

# packages
    foreach ($item in $config.packages) {
        switch ($item) {
            nvim {
                $junction = @{
                    path = "$env:LOCALAPPDATA\nvim"
                    target = "$env:USERPROFILE\.config\nvim"
                }
                New-Junction @junction
                if (!(Test-Path $env:USERPROFILE\.config\nvim)) {
                    $null = New-Item $env:USERPROFILE\.config\nvim -ItemType Directory
                }
                $copy = @{
                    Path = "$PSScriptRoot\.config\nvim\*"
                    Destination = "$env:USERPROFILE\.config\nvim"
                }
                Copy-Item @copy -Recurse -Force
            }
            spt {
                if (!(Test-Path $env:USERPROFILE\.config\spotify-tui)) {
                    $null = New-Item $env:USERPROFILE\.config\spotify-tui -ItemType Directory
                }
                $copy = @{
                    Path = "$PSScriptRoot\.config\spotify-tui\*"
                    Destination = "$env:USERPROFILE\.config\spotify-tui"
                }
                Copy-Item @copy -Recurse -Force
            }
            winfetch {
                if (!(Test-Path $env:USERPROFILE\.config\winfetch)) {
                    $null = New-Item $env:USERPROFILE\.config\winfetch -ItemType Directory
                }
                $copy = @{
                    Path = "$PSScriptRoot\.config\winfetch\*"
                    Destination = "$env:USERPROFILE\.config\winfetch"
                }
                Copy-Item @copy -Recurse -Force
            }
            terminal {
                $junction = @{
                    path = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal*\LocalState"
                    target = "$env:USERPROFILE\.config\terminal"
                }
                New-Junction @junction
                if (!(Test-Path $env:USERPROFILE\.config\terminal)) {
                    $null = New-Item $env:USERPROFILE\.config\terminal -ItemType Directory
                }
                $copy = @{
                    Path = "$PSScriptRoot\.config\terminal\*"
                    Destination = "$env:USERPROFILE\.config\terminal"
                }
                Copy-Item @copy -Recurse -Force
            }
        }
    }