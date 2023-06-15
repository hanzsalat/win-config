<# 
    general options
#>
    $ErrorActionPreference = 'Stop'

<# 
    functions and script blocks 
#>
    function Test-Config {
        param (
            [string]
            $config
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
                                if ($item -notmatch 'glazewm|nvim|winfetch|spt|terminal|helix') {
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

    $windowmanager = {
        if ($data.checked.GlazeWM -and $data.config.windowmanager -eq 'glazewm') {
            if (Test-Path ($paths.startup + '\komorebi.lnk')) {
                Remove-Item ($paths.startup + '\komorebi.lnk')
            }
    
            if (!(Test-Path ($paths.config + '\glazewm'))) {
                New-Item ($paths.config + '\glazewm') -ItemType Directory
            }
    
            $copy = @{
                Path = "$PSScriptRoot\.config\glazewm\$($data.config.workspace).yaml"
                Destination = "$($paths.config)\glazewm\config.yaml"
            }
            Copy-Item @copy -Recurse -Force
    
            $shortcut = @{
                name = 'glazewm'
                target = (Get-Command glazewm).Path
                arguments = "--config=$($paths.config)\glazewm\config.yaml"
                path = $paths.startup
            }
            New-Shortcut @shortcut
    
            Get-Process komorebi -ErrorAction Ignore | Stop-Process
            Get-Process whkd -ErrorAction Ignore | Stop-Process
            if (!(Get-Process glazewm -ErrorAction Ignore)) {
                Invoke-Item ($paths.startup + '\glazewm.lnk')
            }
        }
        elseif ($data.checked.Komorebi -and $data.config.windowmanager -eq 'komorebi') {
                if (Test-Path ($paths.startup + '\glazewm.lnk')) {
                    Remove-Item ($paths.startup + '\glazewm.lnk')
                }
                
                if (!(Test-Path ($paths.config + '\komorebi'))) {
                    New-Item ($paths.config + '\komorebi') -ItemType Directory
                }
    
                $copy = @{
                    Path = "$PSScriptRoot\.config\komorebi\*"
                    Destination = "$($pahts.config)\komorebi"
                }
                Copy-Item @copy -Recurse -Force
    
                $copy = @{
                    Path = "$PSScriptRoot\.config\whkdrc"
                    Destination = $pahts.config
                }
                Copy-Item @copy -Recurse -Force
    
                $shortcut = @{
                    name = 'komorebi'
                    target = "powershell.exe"
                    arguments = '-WindowStyle hidden -Command komorebic start --await-configuration'
                    path = $paths.startup
                }
                New-Shortcut @shortcut
        
                $env:KOMOREBI_CONFIG_HOME = "$($pahts.config)\komorebi"
    
                Get-Process glazewm -ErrorAction Ignore | Stop-Process
                if (!(Get-Process komorebi -ErrorAction Ignore)) {
                    Invoke-Item ($paths.startup + '\komorebi.lnk')
                }
        }
        else {
            if (!$checked.Komorebi) {
                Write-Error 'Missing Komorebi'
            }
            if (!$checked.GlazeWM) {
                Write-Error 'Missing Glaze-WM'
            }
        }
    }

    $taskbar = {
        if ($data.config.taskbar -and $data.checked.Nircmd) {
            $shortcut = @{
                name = 'nircmd'
                target = (Get-Command nircmd).Path
                arguments = 'win trans class Shell_TrayWnd 255'
                path = $paths.startup
            }
            New-Shortcut @shortcut
        } 
        elseif (!$data.config.taskbar -and $data.checked.Nircmd) {
            $shortcut = @{
                name = 'nircmd'
                target = (Get-Command nircmd).Path
                arguments = 'win trans class Shell_TrayWnd 256'
                path = $paths.startup
            }
            New-Shortcut @shortcut
        } 
        else {
            if (!$checked.Nircmd) {
                Write-Error 'Missing Nircmd'
            }
        }
        Invoke-Item ($paths.startup + '\nircmd.lnk')
    }

    $powershell = {
        if (!(Test-Path "$env:USERPROFILE\Documents\PowerShell")) {
            New-Item "$env:USERPROFILE\Documents\PowerShell" -ItemType Directory
        }
        $copy = @{
            Path = "$PSScriptRoot\powershell\*"
            Destination = "$env:USERPROFILE\Documents\PowerShell"
        }
        Copy-Item @copy -Recurse -Force
        $junction = @{
            junction = "$env:USERPROFILE\Documents\WindowsPowerShell"
            path = "$env:USERPROFILE\Documents\PowerShell"
        }
        New-Junction @junction
    }

    $prompt = {
        if ($data.config.prompt -eq 'omp' -and $data.checked.Posh) {
            $data.userconfig['prompt'] = 1
        }
        elseif ($data.config.prompt -eq 'starship' -and $data.checked.Starship) {
            $data.userconfig['prompt'] = 2
        }
    }

    $packages = {
        foreach ($item in $data.config.packages) {
            switch ($item) {
                nvim {
                    if (!(Test-Path ($paths.config + '\nvim'))) {
                        New-Item ($paths.config + '\nvim') -ItemType Directory
                    }
    
                    $copy = @{
                        Path = "$PSScriptRoot\.config\nvim\*"
                        Destination = ($paths.config + '\nvim')
                    }
                    Copy-Item @copy -Recurse -Force
    
                    $junction = @{
                        junction = "$env:LOCALAPPDATA\nvim"
                        path = ($paths.config + '\nvim')
                    }
                    New-Junction @junction  
                }
                spt {
                    if (!(Test-Path ($paths.config + '\spotify-tui'))) {
                        New-Item ($paths.config + '\spotify-tui') -ItemType Directory
                    }
    
                    $copy = @{
                        Path = "$PSScriptRoot\.config\spotify-tui\*"
                        Destination = ($paths.config + '\spotify-tui')
                    }
                    Copy-Item @copy -Recurse -Force
                }
                winfetch {
                    if (!(Test-Path ($paths.config + '\winfetch'))) {
                        New-Item ($paths.config + '\winfetch') -ItemType Directory
                    }
    
                    $copy = @{
                        Path = "$PSScriptRoot\.config\winfetch\*"
                        Destination = ($paths.config + '\winfetch')
                    }
                    Copy-Item @copy -Recurse -Force
                }
                terminal {
                    if (!(Test-Path ($paths.config + '\terminal'))) {
                        New-Item ($paths.config + '\terminal') -ItemType Directory
                    }
    
                    $copy = @{
                        Path = "$PSScriptRoot\.config\terminal\*"
                        Destination = ($paths.config + '\terminal')
                    }
                    Copy-Item @copy -Recurse -Force
    
                    $location = Resolve-Path("$($paths.shims)\..\persist\windows-terminal\settings")
    
                    $junction = @{
                        junction = "$location"
                        path = ($paths.config + '\terminal')
                    }
                    New-Junction @junction
                }
                helix {
                    if (!(Test-Path ($paths.config + '\helix'))) {
                        New-Item ($paths.config + '\helix') -ItemType Directory
                    }
    
                    $copy = @{
                        Path = "$PSScriptRoot\.config\helix\*"
                        Destination = ($paths.config + '\helix')
                    }
                    Copy-Item @copy -Recurse -Force
    
                    $junction = @{
                        junction = "$env:APPDATA\helix"
                        path = ($paths.config + '\helix')
                    }
                    New-Junction @junction
                }
            }
        }
    }

<# 
    init variables,arrays and hastables
#>
    $paths = @{
        startup     = [System.Environment]::GetFolderPath('Startup')
        shims       = $env:Path.Split(';').Where({$_ -match 'shims'}) | Out-String
        config      = $env:USERPROFILE + '\.config'
    }

    $data = @{
        config      = Test-Config -config $PSScriptRoot\config.ps1
        avaible     = . $PSScriptRoot\.config\avaible.ps1
        checked     = & $PSScriptRoot\powershell\Scripts\powershell.check.ps1
        userconfig  = New-Object -TypeName hashtable
    }

    $shortcut = New-Object -TypeName hashtable
    $junction = New-Object -TypeName hashtable
    $copy     = New-Object -TypeName hashtable

<#
    script itself
#>
    & $windowmanager

    & $taskbar

    & $powershell

    & $prompt

    & $packages

    $item = @{
        Path = "$env:USERPROFILE\Documents\PowerShell\userconfig.json"
        Value = ($data.userconfig | ConvertTo-Json)
    }
    New-Item @item -Force

    & $Profile.CurrentUserAllHosts