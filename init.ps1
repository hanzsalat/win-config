# default error handling
$ErrorActionPreference = 'Stop'
# get userconfig
$config = Get-Content $PSScriptRoot\userconfig.json | ConvertFrom-Json
# check fo installed software
[hashtable]$checked = & $PSScriptRoot\powershell\Scripts\powershell.check.ps1
# path to the startup folder
[string]$startupPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
# init arraylists
$shortcuts = New-Object System.Collections.ArrayList
$junctions = New-Object System.Collections.ArrayList

function New-Shortcut {
    param(
        [string]
        # Specifies the file name
        $name,
        # Spcifies the target of the shortcut
        $target,
        # add arguments if needed
        $arguments,
        # path to where the shortcut should be generated
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

function Out-Error {
    param(
        [string]
        # error message
        $msg,
        # error escalation
        $escnum
    )

    switch($escnum) {
        0 {
            Write-Warning $msg
        }
        1{
            Write-Error $msg
        }
        2 {
            Write-Error $msg
            Exit
        }
        default {
            Write-Debug 'Something wrong with error handling'
        }
    }
}

# take actions on stuff in the userconfig file

# windowmanager
# glazewm
    if ($config.windowmanager -eq 'glazewm' -and $checked.GlazeWM) {
        # check for komorebi shortcut and delete it
            if (Test-Path "$startupPath\komorebi.lnk") {
                Remove-Item -Path "$startupPath\komorebi.lnk"
            }
        # add glazewm to $shortcuts
            [void]$shortcuts.Add(@{
                name = 'glazewm'
                target = "powershell.exe"
                arguments = "-WindowStyle hidden -Command glazewm --config=$env:USERPROFILE\.config\glaze-wm\$($config.workspace).yaml"
                path = $startupPath
            })
        # copy .config files
            Copy-Item -Path $PSScriptRoot\.config\glaze-wm -Destination $env:USERPROFILE\.config -Recurse -Force
    }
# komorebi
    elseif ($config.windowmanager -eq 'komorebi' -and $checked.Komorebi) {
        # check for glazewm shortcut and delete it
            if (Test-Path "$startupPath\glazewm.lnk") {
                Remove-Item -Path "$startupPath\glazewm.lnk"
            }
        # add komorebi to $shortcuts
            [void]$shortcuts.Add(@{
                name = 'komorebi'
                target = "powershell.exe"
                arguments = '-WindowStyle hidden -Command komorebic start --await-configuration'
                path = $startupPath
            })
        # copy .config files
            Copy-Item -Path $PSScriptRoot\.config\komorebi -Destination $env:USERPROFILE\.config -Recurse -Force
    }
# error handling
    else {
        if (!$checked.Komorebi -and $config.windowmanager -eq 'komorebi') {
            Out-Error -msg 'Missing Komorebi' -escnum 1 
        }
        if (!$checked.GlazeWM -and $config.windowmanager -eq 'glazewm') {
            Out-Error -msg 'Missing Glaze-WM' -escnum 1
        }
        if ($config.windowmanager -ne ('komorebi' -or 'glazewm')) {
            Out-Error -msg "Incorrect name of Windowmanager: $($config.windowmanager)" -escnum 0
        }
    }

# taskbar
# Check for bool type
    if ($config.taskbar.GetType().name -ne 'Boolean') {
        Out-Error -msg "Incorrect data type of taskbar setting: $($config.taskbar)" -escnum 2
    }
# show taskbar
    elseif ($config.taskbar -and $checked.Nircmd) {
        [void]$shortcuts.Add(@{
            name = 'nircmd'
            target = (Get-Command nircmd).Path
            arguments = 'win trans class Shell_TrayWnd 255'
            path = $startupPath
        })
    }
# remove taskbar
    elseif (!$config.taskbar -and $checked.Nircmd) {
        [void]$shortcuts.Add(@{
            name = 'nircmd'
            target = (Get-Command nircmd).Path
            arguments = 'win trans class Shell_TrayWnd 256'
            path = $startupPath
        })
    }
# error handling
    else {
        if (!$checked.Nircmd) {
            Out-Error -msg 'Missing Nircmd' -escnum 1
        }
    }

# powershell + terminal
    [void]$junctions.Add(@{
        path = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal*\LocalState"
        target = "$env:USERPROFILE\.config\terminal"
    })
    [void]$junctions.Add(@{
        path = "$env:USERPROFILE\Documents\WindowsPowerShell"
        target = "$env:USERPROFILE\Documents\PowerShell"
    })
    Copy-Item -Path $PSScriptRoot\powershell\* -Destination $env:USERPROFILE\Documents\PowerShell -Recurse -Force
# oh-my-posh
    if ($config.prompt -eq 'omp' -and $checked.Posh) {
        $null = New-Item -Path $env:USERPROFILE\Documents\PowerShell\config.json -Value '{"prompt": 1}' -Force
    }
# starship
    elseif ($config.prompt -eq 'starship' -and $checked.Starship) {
        $null = New-Item -Path $env:USERPROFILE\Documents\PowerShell\config.json -Value '{"prompt": 2}' -Force
    }

# packages
<#
    $config.packages.foreach($item ,{
        switch ($item) {
            glazewm {
            	
            }
            nvim {

            }
            scoop {

            }
            nvim {

            }
            winfetch {

            }
        }
    })
#>

# create junctions for every item in $junctions
foreach ($item in $junctions) {
    New-Junction @item
}

# create shortcut for every item in $shortcuts
foreach ($item in $shortcuts) {
    New-Shortcut @item
}

<#
# re route the nvim config folder to .config\nvim
    [void]$junctions.Add(@{
        path = "$env:LOCALAPPDATA\nvim"
        target = "$env:USERPROFILE\.config\nvim"
    })

# copy items to their destination
    Copy-Item -Path $PSScriptRoot\powershell\* -Destination $env:USERPROFILE\Documents\PowerShell\ -Recurse -Force
    Copy-Item -Path $PSScriptRoot\.config\* -Destination $env:USERPROFILE\.config -Recurse -Force 
#>
