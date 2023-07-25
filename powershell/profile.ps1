# general settings
    $ErrorActionPreference = 'Continue'

# get $checked from powershell.check.ps1 script
    $checked = & $PSScriptRoot\Scripts\powershell.check.ps1

# import content of userconfig
    $userconfig = Get-Content $PSScriptRoot\userconfig.json | ConvertFrom-Json

# import user aliases
    . $PSScriptRoot\Scripts\powershell.alias.ps1

# import user functions
    . $PSScriptRoot\Scripts\powershell.functions.ps1

# import mainload
    . $PSScriptRoot\Scripts\powershell.mainload.ps1

# import completions
    . $PSScriptRoot\Scripts\powershell.completion.ps1

# import offload
    . $PSScriptRoot\Scripts\powershell.settings.ps1