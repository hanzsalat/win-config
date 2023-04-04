# general variable
    $ErrorActionPreference = 'Ignore'

# copy items to their destination
    Copy-Item -Path $PSScriptRoot\powershell\* -Destination $env:USERPROFILE\Documents\WindowsPowerShell\ -Recurse -Force
    Copy-Item -Path $PSScriptRoot\.config\* -Destination $env:USERPROFILE\.config -Recurse -Force

# create junctions for convienince
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

# init $list as arraylist
    $list = [System.Collections.ArrayList]::new()

# add WindowsTerminal localstate folder to list
    [void]$list.Add(@{
        path = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal*\LocalState"
        target = "$env:USERPROFILE\.config\terminal"
    })

# add PowerShell user folder to list
    [void]$list.Add(@{
        path = "$env:USERPROFILE\Documents\PowerShell"
        target = "$env:USERPROFILE\Documents\WindowsPowerShell"
    })

# create junctions for every item in $list
    foreach ($item in $list) {
        & $createJunction @item
    }

# create shortcuts in startup for komorebi and nircmd
# path to windows startup folder
    $startupPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"

# scriptblock for creating a shortcut
    $createLink = {
        param( $name,$sourceExe,$argumentsExe,$destination )
        $WshShell = New-Object -comObject WScript.Shell
        $shortcut = $WshShell.CreateShortcut("$destination\$name.lnk")
        $shortcut.TargetPath = $sourceExe
        $shortcut.Arguments = $argumentsExe
        $shortcut.Save()
    }

# init $list as arraylist
    $list = [System.Collections.ArrayList]::new()

# add nircmd to list
    [void]$list.Add(@{
        name = 'nircmd'
        sourceExe = (Get-Command nircmd).Path
        argumentsExe = 'win trans class Shell_TrayWnd 255'
        destination = $startupPath
    })

# add komorebi to list
    [void]$list.Add(@{
        name = 'komorebi'
        sourceExe = "powershell.exe"
        argumentsExe = '-WindowStyle hidden -Command komorebic start --await-configuration'
        destination = $startupPath
    })

# create shortcut for every item in $list
    foreach ($item in $list) {
        if (!(Test-Path -Path "$startupPath\$($item.name).lnk")) {
            & $createLink @item
        } else {
            $null = Remove-Item -Path "$startupPath\$($item.name).lnk"
            & $createLink @item
        }
    }