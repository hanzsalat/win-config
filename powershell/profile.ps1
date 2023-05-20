# stopwatch to measure loading speeds of profile
    #$stopwatch = [system.diagnostics.stopwatch]::StartNew()

# get $checked from powershell.check.ps1 script
    if (!(Test-Path $PSScriptRoot\Locals\checked.json)) {
        & $PSScriptRoot\Scripts\powershell.check.ps1 | ConvertTo-Json | Out-File $PSScriptRoot\Locals\checked.json
    }
    else {
        $checked = Get-Content $PSScriptRoot\Locals\checked.json | ConvertFrom-Json
    }

# import content of userconfig
    $userconfig = Get-Content $PSScriptRoot\Locals\userconfig.json | ConvertFrom-Json

# import user aliases
    . $PSScriptRoot\Scripts\powershell.alias.ps1

# import user functions
    . $PSScriptRoot\Scripts\powershell.functions.ps1

# import completions
    . $PSScriptRoot\Scripts\powershell.completion.ps1

# import offload
    . $PSScriptRoot\Scripts\powershell.settings.ps1

# import mainload
    . $PSScriptRoot\Scripts\powershell.mainload.ps1

# stop stopwatch and output the total milliseconds of loading the profile    
    #$stopwatch.Stop()
    #$stopwatch.ElapsedMilliseconds