# general variable
    $ErrorActionPreference = 'Ignore'

# import userconfig
    $config = Import-PowerShellDataFile $PSScriptRoot\userconfig.psd1 -ErrorAction Stop

# check for installed software
    $checked = & $PSScriptRoot\powershell\Scripts\powershell.check.ps1

# path to windows startup folder
    $startupPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"

# init $shortcuts as arraylist
    $shortcuts = [System.Collections.ArrayList]::new()

# init $junctions as arraylist
    $junctions = [System.Collections.ArrayList]::new()

# scriptblock for creating a shortcut
    $createLink = {
        param( $name,$sourceExe,$argumentsExe,$destination )
        $WshShell = New-Object -comObject WScript.Shell
        $shortcut = $WshShell.CreateShortcut("$destination\$name.lnk")
        $shortcut.TargetPath = $sourceExe
        $shortcut.Arguments = $argumentsExe
        $shortcut.Save()
    }

# Script block to copy old files to tmp and put them back into the target of junction
    $createJunction = {
        param( $path,$target )
        $guid = New-Guid
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

# error out if missing software 

# take actions on stuff in the userconfig file
# windowmanager
    if ($config.windowmanager -eq 'glazewm') {
        # check for komorebi shortcut and delete it
            if (Test-Path "$startupPath\komorebi.lnk") {
                Remove-Item -Path "$startupPath\komorebi.lnk"
            }
        # add glazewm to $shortcuts
            [void]$shortcuts.Add(@{
                name = 'glazewm'
                sourceExe = "powershell.exe"
                argumentsExe = "-WindowStyle hidden -Command glazewm --config=$env:USERPROFILE\.config\glaze-wm\$($config.workspace).yaml"
                destination = $startupPath
            })
    } 
    else {
        # check for glazewm shortcut and delete it
            if (Test-Path "$startupPath\glazewm.lnk") {
                Remove-Item -Path "$startupPath\glazewm.lnk"
            }
        # add komorebi to $shortcuts
            [void]$shortcuts.Add(@{
                name = 'komorebi'
                sourceExe = "powershell.exe"
                argumentsExe = '-WindowStyle hidden -Command komorebic start --await-configuration'
                destination = $startupPath
            })
    }

# taskbar setting
    if ($config.taskbar) {
        # add nircmd to $shortcuts with 255
            [void]$shortcuts.Add(@{
                name = 'nircmd'
                sourceExe = (Get-Command nircmd).Path
                argumentsExe = 'win trans class Shell_TrayWnd 255'
                destination = $startupPath
            })
    } 
    else {
        # add nircmd to $shortcuts with 256
            [void]$shortcuts.Add(@{
                name = 'nircmd'
                sourceExe = (Get-Command nircmd).Path
                argumentsExe = 'win trans class Shell_TrayWnd 256'
                destination = $startupPath
            })
    }

# add WindowsTerminal localstate folder to $junctions
    [void]$junctions.Add(@{
        path = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal*\LocalState"
        target = "$env:USERPROFILE\.config\terminal"
    })

# add PowerShell user folder to $junctions
    [void]$junctions.Add(@{
        path = "$env:USERPROFILE\Documents\PowerShell"
        target = "$env:USERPROFILE\Documents\WindowsPowerShell"
    })

# create junctions for every item in $junctions
    foreach ($item in $junctions) {
        & $createJunction @item
    }

# create shortcut for every item in $shortcuts
    foreach ($item in $shortcuts) {
        if (!(Test-Path -Path "$startupPath\$($item.name).lnk")) {
            & $createLink @item
        } else {
            $null = Remove-Item -Path "$startupPath\$($item.name).lnk"
            & $createLink @item
        }
    }

# copy items to their destination
    Copy-Item -Path $PSScriptRoot\powershell\* -Destination $env:USERPROFILE\Documents\WindowsPowerShell\ -Recurse -Force
    Copy-Item -Path $PSScriptRoot\.config\* -Destination $env:USERPROFILE\.config -Recurse -Force 