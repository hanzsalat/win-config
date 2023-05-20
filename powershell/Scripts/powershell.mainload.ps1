# ignore errors
$ErrorActionPreference = 'Continue'

# load main components
    if ($checked.ChocoQAC) {Import-Module $env:ChocolateyInstall\helpers\chocolateyProfile.psm1 }
    if ($checked.ScoopQAC) {Import-Module scoop-completion}
    if ($checked.PSWindowsUpdate) {Import-Module PSWindowsUpdate}
    if ($checked.TerminalIcons) {Import-Module Terminal-Icons}
    if ($Host.Name -eq 'ConsoleHost') {
        if ($checked.Posh -and $userconfig.prompt -eq 1) {oh-my-posh init pwsh --config $PSScriptRoot\..\Themes\zash_V2.omp.json | Invoke-Expression}
        if ($checked.Starship -and $userconfig.prompt -eq 2) {& ([ScriptBlock]::Create((starship init powershell)))}
    }