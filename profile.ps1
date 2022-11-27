# Init OMP with config
oh-my-posh init pwsh --config 'https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/lambda.omp.json' | Invoke-Expression

# Import Packwiz auto completion
Import-Module PackwizCompletion

# enable completion in current shell, use absolute path because PowerShell Core not respect $env:PSModulePath
Import-Module "$($(Get-Item $(Get-Command scoop.ps1).Path).Directory.Parent.FullName)\modules\scoop-completion"

# Choco completion for powershell
Import-Module “$env:ChocolateyInstall\helpers\chocolateyProfile.psm1” -Force

# Quick access to navigate on system
$downloads = $home + '\Downloads'
$desktop = $home + '\Desktop'
$documents = $home + '\Documents'
$git = $home + '\Documents\GitHub'
$mc = $env:SystemDrive + '\Games\Games 2\Minecraft'

# Add/Change Aliases
Set-Alias -Name 'omp' -Value "oh-my-posh.exe" -Description 'Oh-My-Posh short alias'
Set-Alias -Name 'pw' -Value "packwiz.exe" -Description 'Packwiz short alias'
Set-Alias -Name 'gwu' -Value "Get-WindowsUpdate" -Description 'Get-WindowsUpdate short alias'
Set-Alias -Name 'iwu' -Value "Install-WindowsUpdate" -Description 'Install-WindowsUpdate short alias'
Set-Alias -Name 'gic'  "Get-ItemCount" -Description 'Get-ItemCount short alias'
Set-Alias -Name 'fci' -Value "Find-ChildItem" -Description 'Find-ChildItem short alias'
Set-Alias -Name 'scmd' -Value "Search-Command" -Description 'Search-Command short alias'