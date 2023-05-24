$ErrorActionPreference = 'Ignore'

$check = @{}
$commands = Get-Command -CommandType Application
$modules = Get-Module -ListAvailable
# based on application
$check['Choco']           = $commands.Where({$_.Name -contains 'choco.exe'}).path
$check['GlazeWM']         = $commands.Where({$_.Name -contains 'glazewm.exe'}).path
$check['Komorebi']        = $commands.Where({$_.Name -contains 'komorebi.exe'}).path
$check['Nircmd']          = $commands.Where({$_.Name -contains 'nircmd.exe'}).path
$check['Op']              = $commands.Where({$_.Name -contains 'op.exe'}).path
$check['Packwiz']         = $commands.Where({$_.Name -contains 'packwiz.exe'}).path
$check['Posh']            = $commands.Where({$_.Name -contains 'oh-my-posh.exe'}).path
$check['Scoop']           = $commands.Where({$_.Name -contains 'scoop.cmd'}).path
$check['SpotifyTui']      = $commands.Where({$_.Name -contains 'spt.exe'}).path
$check['Starship']        = $commands.Where({$_.Name -contains 'starship.exe'}).path
$check['Winfetch']        = $commands.Where({$_.Name -contains 'winfetch.cmd'}).path
$check['PowerShell']      = $commands.Where({$_.Name -contains 'powershell.exe'}).path
$check['Pwsh']            = $commands.Where({$_.Name -contains 'pwsh.exe'}).path
$check['Neovim']          = $commands.Where({$_.Name -contains 'nvim.exe'}).path
$check['Helix']           = $commands.Where({$_.Name -contains 'helix.exe'}).path
$check['VScode']          = $commands.Where({$_.Name -contains 'code.cmd'}).path
$check['WinGet']          = $commands.Where({$_.Name -contains 'code.cmd'}).path
$check['Whkd']            = $commands.Where({$_.Name -contains 'code.cmd'}).path
# based on modules
$check['PSWindowsUpdate'] = $modules.Where({$_.Name -contains 'PSWindowsUpdate'}).path | Select-Object -First 1
$check['TerminalIcons']   = $modules.Where({$_.Name -contains 'Terminal-Icons'}).path | Select-Object -First 1

$checked = @{}
foreach ($item in $check.GetEnumerator()) {
    if ([System.IO.File]::Exists($item.Value)) { $checked[$item.Key] = $true }
    else { $checked[$item.Key] = $false }
}

$null = $check
$null = $commands
$null = $modules

return $checked