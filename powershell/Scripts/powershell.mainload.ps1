Import-Module -Name "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1" -ErrorAction SilentlyContinue
Import-Module -Name 'scoop-completion' -ErrorAction SilentlyContinue
Import-Module -Name 'PSWindowsUpdate' -ErrorAction SilentlyContinue
if ($PSVersionTable.PSVersion.Major -eq 7) {
    Import-Module -Name 'Terminal-Icons' -ErrorAction SilentlyContinue
}

if ($Host.Name -eq 'ConsoleHost') {
    if ($checked.Posh -and $userconfig.prompt -eq 1) {
        $env:POSH_THEME = "$env:USERPROFILE\Documents\WindowsPowerShell\Themes\zash.omp.toml"
        Invoke-Expression (&oh-my-posh init pwsh) -ErrorAction SilentlyContinue
    }
    if ($checked.Starship -and $userconfig.prompt -eq 2) {
        $env:STARSHIP_CONFIG = "$env:USERPROFILE\Documents\WindowsPowerShell\Themes\starship.toml"
        Invoke-Expression (&starship init powershell) -ErrorAction SilentlyContinue
    }
}