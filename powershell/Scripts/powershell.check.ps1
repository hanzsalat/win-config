# general variables
$ErrorActionPreference = 'Ignore'

# generate list of items that need to be checked
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
    $check['Terminal']        = $commands.Where({$_.Name -contains 'wt.exe'}).path
    $check['Powershell']      = $commands.Where({$_.Name -contains 'powershell.exe'}).path
    $check['Pwsh']            = $commands.Where({$_.Name -contains 'pwsh.exe'}).path
    $check['Neovim']          = $commands.Where({$_.Name -contains 'nvim.exe'}).path
    $check['Helix']           = $commands.Where({$_.Name -contains 'helix.exe'}).path
    $check['Vscode']          = $commands.Where({$_.Name -contains 'code.cmd'}).path
    # based on modules
    $check['PSWindowsUpdate'] = $modules.Where({$_.Name -contains 'PSWindowsUpdate'}).path | Select-Object -First 1
    $check['RandomUtils']     = $modules.Where({$_.Name -contains 'Random-Utils'}).path | Select-Object -First 1
    $check['TerminalIcons']   = $modules.Where({$_.Name -contains 'Terminal-Icons'}).path | Select-Object -First 1
    # completions
    $check['ChocoQAC']        = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
    $check['OpQAC']           = $modules.Where({$_.Name -contains 'op-completion'}).path | Select-Object -First 1
    $check['PackwizQAC']      = $modules.Where({$_.Name -contains 'packwiz-completion'}).path | Select-Object -First 1
    $check['ScoopQAC']        = $modules.Where({$_.Name -contains 'scoop-completion'}).path | Select-Object -First 1
    $check['SpotifyTuiQAC']   = $modules.Where({$_.Name -contains 'spt-completion'}).path | Select-Object -First 1
    $null = $commands
    $null = $modules
    
# generate a list that holds $true/$false for each key of $check based on if an item exists
    $checked = @{}
    # loop through every item in $check
    foreach ($item in $check.GetEnumerator()) {
        if ([System.IO.File]::Exists($item.Value)) { $checked[$item.Key] = $true }
        else { $checked[$item.Key] = $false }
    }

# clear $check
    $null = $check

# return the list $checked as an hashtable
    return [hashtable]$checked