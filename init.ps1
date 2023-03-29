# general variable
    $ErrorActionPreference = 'Ignore'

# copy items to their destination
    Copy-Item -Path $PSScriptRoot\powershell\* -Destination $env:USERPROFILE\Documents\WindowsPowerShell\ -Recurse -Force
    Copy-Item -Path $PSScriptRoot\.config\* -Destination $env:USERPROFILE\.config -Recurse -Force

# create junctions for convienince
    if (!(Test-Path $env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState)) {
        $path = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
        $target = "$env:USERPROFILE\.config\terminal"
        New-Item -ItemType Junction -Path $path -Target $target -Force
    }
    if (!(Test-Path $env:USERPROFILE\Documents\PowerShell)) {
        $path = "$env:USERPROFILE\Documents\PowerShell"
        $target = "$env:USERPROFILE\Documents\WindowsPowerShell"
        New-Item -ItemType Junction -Path $path -Target $target -Force
    }
    # register new tasks for komorebi and nircmd
    if ($null -eq (Get-ScheduledTask -TaskName nircmd).TaskName) {
        $trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:username
        $file = "$env:USERPROFILE\Documents\WindowsPowerShell\Scripts\nircmd.startup.ps1"
        $argument = '-WindowStyle hidden -File ' + '"' + $file + '"'
        switch ($PSVersionTable.PSversion.Major) {
            5 { $psname = 'powershell.exe' }
            7 { $psname = 'pwsh.exe' }
            Default { exit }
        }
        $action = New-ScheduledTaskAction -Execute "$PSHOME\$psname" -Argument $argument
        $settings = New-ScheduledTaskSettingsSet -Priority 7 -AllowStartIfOnBatteries
        Register-ScheduledTask -TaskName 'nircmd' -Trigger $trigger -Action $action -User $env:username -Settings $settings
    }
    if ($null -eq (Get-ScheduledTask -TaskName komorebi).TaskName) {
        $trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:username
        $file = "$env:USERPROFILE\Documents\WindowsPowerShell\Scripts\komorebi.startup.ps1"
        $argument = '-WindowStyle hidden -File ' + '"' + $file + '"'
        switch ($PSVersionTable.PSversion.Major) {
            5 { $psname = 'powershell.exe' }
            7 { $psname = 'pwsh.exe' }
            Default { exit }
        }
        $action = New-ScheduledTaskAction -Execute "$PSHOME\$psname" -Argument $argument
        $settings = New-ScheduledTaskSettingsSet -Priority 7 -AllowStartIfOnBatteries
        Register-ScheduledTask -TaskName 'komorebi' -Trigger $trigger -Action $action -User $env:username -Settings $settings
    }

# for debug
    Start-Sleep 10