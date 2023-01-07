# Init OMP with config
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\zash.omp.json" | Invoke-Expression

# Import modules
Get-InstalledModule |
ForEach-Object { Import-Module $_.name }
Import-Module Random-Utils

# Import auto completions
Import-Module PackwizCompletion
Import-Module "$($(Get-Item $(Get-Command scoop.ps1).Path).Directory.Parent.FullName)\modules\scoop-completion"
Import-Module “$env:ChocolateyInstall\helpers\chocolateyProfile.psm1”

# Quick access to navigate on system
$dwnld = $home + '\Downloads'
$dskt = $home + '\Desktop'
$doc = $home + '\Documents'
$git = $home + '\Documents\GitHub'
$mc = $env:SystemDrive + '\Games\Games 2\Minecraft'

# Add/Change Aliases
Set-Alias -Name 'omp' -Value "oh-my-posh" -Description 'Oh-My-Posh short alias'
Set-Alias -Name 'pw' -Value "packwiz" -Description 'Packwiz short alias'
Set-Alias -Name 'gwu' -Value "Get-WindowsUpdate" -Description 'Get-WindowsUpdate short alias'
Set-Alias -Name 'iwu' -Value "Install-WindowsUpdate" -Description 'Install-WindowsUpdate short alias'