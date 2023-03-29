

<# new design to create shortcuts in startup folder for komorebi and nircmd
# path to windows startup folder
    $startupPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"

# scriptblock for creating a shortcut
    $createLink = {
        param($name,$sourceExe,$argumentsExe,$destination)
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
        sourceExe = (Get-Command komorebi).Path
        argumentsExe = 'start'
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
#>

<# old register for tasks to auto start komorebi and nircmd
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
#>