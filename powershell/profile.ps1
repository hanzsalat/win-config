# stopwatch to measure loading speeds of profile
    #$stopwatch = [system.diagnostics.stopwatch]::StartNew()

# get $checked from powershell.check.ps1 script
    if (![System.IO.File]::Exists("$PSScriptRoot\checked.json")) {
        & $PSScriptRoot\Scripts\powershell.check.ps1 | ConvertTo-Json | Out-File $PSScriptRoot\checked.json
    }
    while (![System.IO.File]::Exists("$PSScriptRoot\checked.json")) {}
    $checked = [System.IO.File]::ReadAllText("$PSScriptRoot\checked.json") | ConvertFrom-Json

# import content of config
    $userconfig = . $PSScriptRoot\userconfig.ps1

# import user aliases
    . $PSScriptRoot\Scripts\powershell.alias.ps1

# import user functions
    . $PSScriptRoot\Scripts\powershell.functions.ps1

# import offload
    . $PSScriptRoot\Scripts\powershell.offload.ps1

# import mainload
    . $PSScriptRoot\Scripts\powershell.mainload.ps1

# stop stopwatch and output the total milliseconds of loading the profile    
    #$stopwatch.Stop()
    #$stopwatch.ElapsedMilliseconds