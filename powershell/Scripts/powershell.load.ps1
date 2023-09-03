if ($checked.{Scoop-Completion}.exists) {
    Import-Module -Name 'scoop-completion'
}

if ($PSVersionTable.PSVersion.Major -eq 7 -and $checked.{Terminal-Icons}.exists) {
    Import-Module -Name 'Terminal-Icons'
}

if ($Host.Name -eq 'ConsoleHost') {
    if ($checked.Posh.exists -and $userconfig.prompt.omp) {
        $env:POSH_THEME = $userconfig.prompt.themePath + '\zash.omp.toml'
        Invoke-Expression (&oh-my-posh init pwsh)
    }
    if ($checked.Starship.exists -and $userconfig.prompt.starship) {
        $env:STARSHIP_CONFIG = $userconfig.prompt.themePath + '\starship.toml'
        Invoke-Expression (&starship init powershell)
    }
}