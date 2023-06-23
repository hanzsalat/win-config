$check = New-Object -TypeName hashtable
$checked = New-Object -TypeName hashtable
$commands = Get-Command -CommandType Application

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
$check['Pwsh']            = $commands.Where({$_.Name -contains 'pwsh.exe'}).path | Select-Object -First 1
$check['Neovim']          = $commands.Where({$_.Name -contains 'nvim.exe'}).path
$check['Helix']           = $commands.Where({$_.Name -contains 'helix.exe'}).path
$check['VScode']          = $commands.Where({$_.Name -contains 'code.cmd'}).path
$check['WinGet']          = $commands.Where({$_.Name -contains 'winget.exe'}).path
$check['Whkd']            = $commands.Where({$_.Name -contains 'whkd.exe'}).path
$check['Terminal']        = $commands.Where({$_.Name -contains 'wt.exe'}).path

foreach ($item in $check.GetEnumerator()) {
    if ([System.IO.File]::Exists($item.Value)) { $checked[$item.Key] = $true }
    else { $checked[$item.Key] = $false }
}

$check,$commands = $null

return $checked