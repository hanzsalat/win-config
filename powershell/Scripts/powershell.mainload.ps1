# load choco completion
    Import-Module -Name "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1" -ErrorAction Ignore

# load scoop completion
    Import-Module -Name 'scoop-completion' -ErrorAction Ignore

# load pswindowsupdate module
    Import-Module -Name 'PSWindowsUpdate' -ErrorAction Ignore

# load terminalicons module if psversion is 7
    if ($PSVersionTable.PSVersion.Major -eq 7) {
        Import-Module -Name 'Terminal-Icons' -ErrorAction Ignore
    }

# load prompt if hostname is console
    if ($Host.Name -eq 'ConsoleHost') {
        if ($checked.Posh -and $userconfig.Prompt.Posh) {
            $env:POSH_THEME = "$env:USERPROFILE\Documents\WindowsPowerShell\Themes\zash.omp.toml"
            Invoke-Expression (&oh-my-posh init pwsh)
        }
        if ($checked.Starship -and $userconfig.Prompt.Starship) {
            $env:STARSHIP_CONFIG = "$env:USERPROFILE\Documents\WindowsPowerShell\Themes\starship.toml"
            Invoke-Expression (&starship init powershell)
        }
    }