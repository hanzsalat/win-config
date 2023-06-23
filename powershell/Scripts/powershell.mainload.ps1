Import-Module -Name "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
Import-Module -Name 'scoop-completion'
Import-Module -Name 'PSWindowsUpdate'
Import-Module -Name 'Terminal-Icons'

if ($Host.Name -eq 'ConsoleHost') {
    if ($checked.Posh -and $userconfig.prompt -eq 1) {
        $env:POSH_THEME = "$env:USERPROFILE\Documents\WindowsPowerShell\Themes\zash.omp.toml"
        Invoke-Expression (&oh-my-posh init pwsh)
    }
    if ($checked.Starship -and $userconfig.prompt -eq 2) {
        $env:STARSHIP_CONFIG = "$env:USERPROFILE\Documents\WindowsPowerShell\Themes\starship.toml"
        Invoke-Expression (&starship init powershell)
    }
}