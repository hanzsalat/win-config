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

$config = Test-Config
$checked = & $PSScriptRoot\powershell\Scripts\powershell.check.ps1
$startupPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
$userconfig = New-Object -TypeName hashtable
$shims = $env:Path.Split(';').Where({$_ -match 'shims'})

if ($checked.GlazeWM -and $config.windowmanager -eq 'glazewm') {
        if (Test-Path "$startupPath\komorebi.lnk") {
            [void](Remove-Item -Path "$startupPath\komorebi.lnk" -Force)
        }
        $shortcut = @{
            name = 'glazewm'
            target = "powershell.exe"
            arguments = "-WindowStyle hidden -Command glazewm --config=$env:USERPROFILE\.config\glaze-wm\config.yaml"
        }
        [void](New-Shortcut @shortcut)
        if (!(Test-Path $env:USERPROFILE\.config\glaze-wm)) {
            [void](New-Item $env:USERPROFILE\.config\glaze-wm -ItemType Directory)
        }
        $copy = @{
            Path = "$PSScriptRoot\.config\glaze-wm\$($config.workspace).yaml"
            Destination = "$env:USERPROFILE\.config\glaze-wm\config.yaml"
        }
        [void](Copy-Item @copy -Recurse -Force)
        Get-Process komorebi -ErrorAction Ignore | Stop-Process
        Get-Process whkd -ErrorAction Ignore | Stop-Process
        if (!(Get-Process glazewm)) {
            Invoke-Item $startupPath\glazewm.lnk
        }
}
elseif ($checked.Komorebi -and $checked.Whkd -and $config.windowmanager -eq 'komorebi') {
        if (Test-Path "$startupPath\glazewm.lnk") {
            [void](Remove-Item -Path "$startupPath\glazewm.lnk")
        }
        $shortcut = @{
            name = 'komorebi'
            target = "powershell.exe"
            arguments = '-WindowStyle hidden -Command komorebic start --await-configuration'
        }
        [void](New-Shortcut @shortcut)
        if (!(Test-Path $env:USERPROFILE\.config\komorebi)) {
            $null = New-Item $env:USERPROFILE\.config\komorebi -ItemType Directory
        }
        $copy = @{
            Path = "$PSScriptRoot\.config\komorebi\*"
            Destination = "$env:USERPROFILE\.config\komorebi"
        }
        [void](Copy-Item @copy -Recurse -Force)
        if (!(Test-Path $env:USERPROFILE\.config\whkd)) {
            $null = New-Item $env:USERPROFILE\.config\whkd -ItemType Directory
        }
        $copy = @{
            Path = "$PSScriptRoot\.config\whkdrc"
            Destination = "$env:USERPROFILE\.config"
        }
        [void](Copy-Item @copy -Recurse -Force)
        $env:KOMOREBI_CONFIG_HOME = "$env:USERPROFILE\.config\komorebi"
        Get-Process glazewm -ErrorAction Ignore | Stop-Process
        if (!(Get-Process komorebi)) {
            Invoke-Item $startupPath\komorebi.lnk
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

if ($config.taskbar -and $checked.Nircmd) {
    $shortcut = @{
        name = 'nircmd'
        target = (Get-Command nircmd).Path
        arguments = 'win trans class Shell_TrayWnd 255'
    }
    [void](New-Shortcut @shortcut)
    Invoke-Item $startupPath\nircmd.lnk
}
elseif (!$config.taskbar -and $checked.Nircmd) {
    $shortcut = @{
        name = 'nircmd'
        target = (Get-Command nircmd).Path
        arguments = 'win trans class Shell_TrayWnd 256'
    }
    [void](New-Shortcut @shortcut)
    Invoke-Item $startupPath\nircmd.lnk
}
else {
    if (!$checked.Nircmd) {
        Write-Error 'Missing Nircmd'
    }
}

$junction = @{
    junction = "$env:USERPROFILE\Documents\WindowsPowerShell"
    path = "$env:USERPROFILE\Documents\PowerShell"
}
[void](New-Junction @junction)
if (!(Test-Path $env:USERPROFILE\Documents\PowerShell)) {
    [void](New-Item $env:USERPROFILE\Documents\PowerShell -ItemType Directory)
}
$copy = @{
    Path = "$PSScriptRoot\powershell\*"
    Destination = "$env:USERPROFILE\Documents\PowerShell"
}
[void](Copy-Item @copy -Recurse -Force)
if ($config.prompt -eq 'omp' -and $checked.Posh) {
    $userconfig['prompt'] = 1
}
elseif ($config.prompt -eq 'starship' -and $checked.Starship) {
    $userconfig['prompt'] = 2
}

foreach ($item in $config.packages) {
    switch ($item) {
        nvim {
            if (!(Test-Path $env:USERPROFILE\.config\nvim)) {
                [void](New-Item $env:USERPROFILE\.config\nvim -ItemType Directory)
            }
            $junction = @{
                junction = "$env:LOCALAPPDATA\nvim"
                path = "$env:USERPROFILE\.config\nvim"
            }
            [void](New-Junction @junction)
            $copy = @{
                Path = "$PSScriptRoot\.config\nvim\*"
                Destination = "$env:USERPROFILE\.config\nvim"
            }
            [void](Copy-Item @copy -Recurse -Force)
        }
        spt {
            if (!(Test-Path $env:USERPROFILE\.config\spotify-tui)) {
                [void](New-Item $env:USERPROFILE\.config\spotify-tui -ItemType Directory)
            }
            $copy = @{
                Path = "$PSScriptRoot\.config\spotify-tui\*"
                Destination = "$env:USERPROFILE\.config\spotify-tui"
            }
            [void](Copy-Item @copy -Recurse -Force)
        }
        winfetch {
            if (!(Test-Path $env:USERPROFILE\.config\winfetch)) {
                [void](New-Item $env:USERPROFILE\.config\winfetch -ItemType Directory)
            }
            $copy = @{
                Path = "$PSScriptRoot\.config\winfetch\*"
                Destination = "$env:USERPROFILE\.config\winfetch"
            }
            [void](Copy-Item @copy -Recurse -Force)
        }
        terminal {
            if (!(Test-Path $env:USERPROFILE\.config\terminal)) {
                [void](New-Item $env:USERPROFILE\.config\terminal -ItemType Directory)
            }
            $location = Resolve-Path("$shims\..\persist\windows-terminal\settings")
            $junction = @{
                junction = "$location"
                path = "$env:USERPROFILE\.config\terminal"
            }
            [void](New-Junction @junction)
            $copy = @{
                Path = "$PSScriptRoot\.config\terminal\*"
                Destination = "$env:USERPROFILE\.config\terminal"
            }
            [void](Copy-Item @copy -Recurse -Force)
        }
        helix {
            if (!(Test-Path $env:USERPROFILE\.config\helix)) {
                [void](New-Item $env:USERPROFILE\.config\helix -ItemType Directory)
            }
            $junction = @{
                junction = "$env:APPDATA\helix"
                path = "$env:USERPROFILE\.config\helix"
            }
            [void](New-Junction @junction)
            $copy = @{
                Path = "$PSScriptRoot\.config\helix\*"
                Destination = "$env:USERPROFILE\.config\helix"
            }
            [void](Copy-Item @copy -Recurse -Force)
        }
    }
}

$item = @{
    Path = "$env:USERPROFILE\Documents\PowerShell\Locals\userconfig.json"
    Value = ($userconfig | ConvertTo-Json)
}
[void](New-Item @item -Force)

$item = @{
    Path = "$env:USERPROFILE\Documents\PowerShell\Locals\checked.json"
    Value = ($checked | ConvertTo-Json)
}
[void](New-Item @item -Force)

& $Profile.CurrentUserAllHosts