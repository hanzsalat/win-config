# general variables
    $ErrorActionPreference = 'Ignore'

# generate list of items that need to be checked
    $check = @{}
    # based on commands
    $check['Choco']           = (Get-Command choco).Path
    $check['Packwiz']         = (Get-Command packwiz).Path
    $check['Posh']            = (Get-Command oh-my-posh).Path
    $check['Komorebi']        = (Get-Command komorebi).Path
    $check['Scoop']           = (Get-Command scoop).Path
    $check['SpotifyTui']      = (Get-Command spt).Path
    $check['Starship']        = (Get-Command starship).Path
    $check['Winfetch']        = (Get-Command winfetch).Path
    # based on modules
    $check['PSWindowsUpdate'] = (Get-Module -ListAvailable -Name PSWindowsUpdate).Path | Select-Object -First 1
    $check['RandomUtils']     = (Get-Module -ListAvailable -Name Random-Utils).Path | Select-Object -First 1
    $check['TerminalIcons']   = (Get-Module -ListAvailable -Name Terminal-Icons).Path | Select-Object -First 1
    # completions
    $check['ChocoQAC']        = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
    $check['OpQAC']           = (Get-Module -ListAvailable -Name OpCompletion).Path | Select-Object -First 1
    $check['PackwizQAC']      = (Get-Module -ListAvailable -Name PackwizCompletion).Path | Select-Object -First 1
    $check['ScoopQAC']        = (Get-Module -ListAvailable -Name scoop-completion).Path | Select-Object -First 1
    $check['SpotifyTuiQAC']   = (Get-Module -ListAvailable -Name SpotifyTuiCompletion).Path | Select-Object -First 1

# generate a list that holds $true/$false for each $check based on if an item exists
    $checked = @{}
    foreach ($content in $check.GetEnumerator()) {
        if ([System.IO.File]::Exists($content.Value)) { $checked[$content.Key] = $true }
        else { $checked[$content.Key] = $false }
    }

# return a list with the name and $true/$false as value
    return $checked