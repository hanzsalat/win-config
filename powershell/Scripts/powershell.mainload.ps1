if ($checked.ChocoQAC) {Import-Module $env:ChocolateyInstall\helpers\chocolateyProfile.psm1 }
if ($checked.ScoopQAC) {Import-Module scoop-completion}
if ($checked.PSWindowsUpdate) {Import-Module PSWindowsUpdate}
if ($checked.TerminalIcons) {Import-Module Terminal-Icons}
if ($Host.Name -eq 'ConsoleHost') {
    if ($checked.Posh -and $userconfig.prompt -eq 1) {
        $env:POSH_THEME = "$env:USERPROFILE\Documents\PowerShell\Themes\zash.omp.toml"
        Invoke-Expression (&oh-my-posh init pwsh)
    }
    if ($checked.Starship -and $userconfig.prompt -eq 2) {
        $env:STARSHIP_CONFIG = "$env:USERPROFILE\Documents\PowerShell\Themes\starship.toml"
        Invoke-Expression (&starship init powershell)
    }
}