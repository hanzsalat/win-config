# get $checked from powershell.check.ps1 script
    if ([System.IO.File]::Exists("$PSScriptRoot\checked.json")) {
        $checked = [System.IO.File]::ReadAllText("$PSScriptRoot\checked.json") | ConvertFrom-Json
    }
    else {
        & $PSScriptRoot\Scripts\powershell.check.ps1 | ConvertTo-Json | Out-File $PSScriptRoot\checked.json
        $checked = [System.IO.File]::ReadAllText("$PSScriptRoot\checked.json") | ConvertFrom-Json
    }

# import user functions
    . $PSScriptRoot\Scripts\powershell.functions.ps1

# import user aliases
    . $PSScriptRoot\Scripts\powershell.alias.ps1

# import offload
    . $PSScriptRoot\Scripts\powershell.offload.ps1

# import mainload
    . $PSScriptRoot\Scripts\powershell.mainload.ps1