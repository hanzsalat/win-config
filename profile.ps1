# Check for installed software
$check = @{
    Scoop = $($env:Path.Split(';').where({$_ -match 'scoop'}))
    Posh = $($env:Path.Split(';').where({$_ -match 'oh-my-posh'}))
    Choco = $env:ChocolateyInstall + '\choco.exe'
    Packwiz = $env:GOPATH + '\bin\packwiz.exe'
    SpotifyTui = $($check.Scoop + '\spt.exe')
}

$checked = @{}

foreach ($content in $check.GetEnumerator()) {
    if (Test-Path $content.Value) { $checked.Add($content.Key,$true) }
    else { $checked.Add($content.Key,$false) }
}

# Import modules
Get-InstalledModule |
ForEach-Object { Import-Module $_.name }

# Set dependecies after check
if ($checked.Posh) { 
    oh-my-posh init pwsh --config "C:\Users\simon\Documents\PowerShell\Themes\zash_V2.omp.json" | Invoke-Expression 
    Set-Alias -Name 'omp' -Value "oh-my-posh" -Description 'Oh-My-Posh short alias'
}
if ($checked.Scoop) { Import-Module "$($(Get-Item $(Get-Command scoop.ps1).Path).Directory.Parent.FullName)\modules\scoop-completion" }
if ($checked.Choco) { Import-Module “$env:ChocolateyInstall\helpers\chocolateyProfile.psm1” }
if ($checkde.Packwiz) { 
    Import-Module PackwizCompletion 
    Set-Alias -Name 'pw' -Value "packwiz" -Description 'Packwiz short alias'
}
if ($checked.SpotifyTui) { Import-Module SpotifyTuiCompletion }

# Quick access to navigate on system
$dwnld = $home + '\Downloads'
$dskt = $home + '\Desktop'
$doc = $home + '\Documents'
$git = $home + '\Documents\GitHub'
$mc = $env:SystemDrive + '\Games\Games 2\Minecraft'

# Add/Change Aliases
Set-Alias -Name 'gwu' -Value "Get-WindowsUpdate" -Description 'Get-WindowsUpdate short alias'
Set-Alias -Name 'iwu' -Value "Install-WindowsUpdate" -Description 'Install-WindowsUpdate short alias'