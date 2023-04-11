# general variable
    $ErrorActionPreference = 'Continue'

# check fo installed software
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

# loop for init stuff based on installed software
    foreach ($item in $checked.GetEnumerator() ) {
        if ($item.value -eq $true) {
            switch ($item.key) {
                Choco {}
                ChocoQAC {}
                GlazeWM {
                    # add glazewm to list
                        [void]$shortcuts.Add(@{
                            name = 'glaze-wm'
                            sourceExe = "powershell.exe"
                            argumentsExe = "-WindowStyle hidden -Command glazewm --config=$env:USERPROFILE\.config\glaze-wm\config.yaml"
                            destination = $startupPath
                        })
                }
                Komorebi {
                    # add komorebi to list
                        [void]$shortcuts.Add(@{
                            name = 'komorebi'
                            sourceExe = "powershell.exe"
                            argumentsExe = '-WindowStyle hidden -Command komorebic start --await-configuration'
                            destination = $startupPath
                        })
                }
                Op {}
                OpQAC {}
                Packwiz {}
                PackwizQAC {}
                Posh {}
                PSWindowsUpdate {}
                RandomUtils {}
                Scoop {}
                ScoopQAC {}
                SpotifyTui {}
                SpotifyTuiQAC {}
                Starship {}
                TerminalIcons {}
                Winfetch {}
                Nircmd {
                    # add nircmd to list
                        [void]$shortcuts.Add(@{
                            name = 'nircmd'
                            sourceExe = (Get-Command nircmd).Path
                            argumentsExe = 'win trans class Shell_TrayWnd 255'
                            destination = $startupPath
                        })
                }
            }
        }
        else {

        }
    }

# add WindowsTerminal localstate folder to list
    [void]$junctions.Add(@{
        path = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal*\LocalState"
        target = "$env:USERPROFILE\.config\terminal"
    })

# add PowerShell user folder to list
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