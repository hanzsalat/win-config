Using namespace System.IO

$checked = New-Object -TypeName hashtable
$commands = Get-Command -CommandType Application

$check = @{
    GlazeWM    = $commands.Where({ $_.Name -contains 'glazewm.exe' }).path
    Komorebi   = $commands.Where({ $_.Name -contains 'komorebi.exe' }).path
    Nircmd     = $commands.Where({ $_.Name -contains 'nircmd.exe' }).path
    Packwiz    = $commands.Where({ $_.Name -contains 'packwiz.exe' }).path
    Posh       = $commands.Where({ $_.Name -contains 'oh-my-posh.exe' }).path
    Scoop      = $commands.Where({ $_.Name -contains 'scoop.cmd' }).path
    SpotifyTui = $commands.Where({ $_.Name -contains 'spt.exe' }).path
    Starship   = $commands.Where({ $_.Name -contains 'starship.exe' }).path
    Winfetch   = $commands.Where({ $_.Name -contains 'winfetch.cmd' }).path
    Pwsh       = $commands.Where({ $_.Name -contains 'pwsh.exe' }).path
    Neovim     = $commands.Where({ $_.Name -contains 'nvim.exe' }).path
    Helix      = $commands.Where({ $_.Name -contains 'helix.exe' }).path
    VScode     = $commands.Where({ $_.Name -contains 'code.cmd' }).path
    WinGet     = $commands.Where({ $_.Name -contains 'winget.exe' }).path
    Whkd       = $commands.Where({ $_.Name -contains 'whkd.exe' }).path
    Terminal   = $commands.Where({ $_.Name -contains 'wt.exe' }).path
}

foreach ($item in $check.GetEnumerator()) {
    if ([File]::Exists(($item.Value | Select-Object -First 1))) { $checked[$item.Key] = $true }
    else { $checked[$item.Key] = $false }
}

return $checked