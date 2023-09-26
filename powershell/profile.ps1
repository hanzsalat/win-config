# general settings
    $ErrorActionPreference = 'Continue'

# get $checked from powershell.checks.ps1 script
    $checked = & $PSScriptRoot\Scripts\powershell.checks.ps1

# import content of userconfig if avaible
    $userconfigPath = $env:USERPROFILE + '\.config\powershell\userconfig.json'
    if (Test-Path $userconfigPath) {
        $userconfig = Get-Content $userconfigPath | ConvertFrom-Json
    }

# import user aliases
    . $PSScriptRoot\Scripts\powershell.aliases.ps1

# import user functions
    . $PSScriptRoot\Scripts\powershell.functions.ps1

# import mainload
    . $PSScriptRoot\Scripts\powershell.load.ps1

# import completions
    . $PSScriptRoot\Scripts\powershell.completions.ps1

# import settings
    . $PSScriptRoot\Scripts\powershell.settings.ps1
