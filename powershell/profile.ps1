# get $checked from powershell.check.ps1 script
    $checked = & $PSScriptRoot\Scripts\powershell.check.ps1

# set dependecies after check
    if ($checked.Komorebi) { $Env:KOMOREBI_CONFIG_HOME = "$env:USERPROFILE\.config\komorebi" }
    if ($checked.PSReadLine) { Import-Module PSReadLine }
    if ($checked.PSWindowsUpdate) { Import-Module PSWindowsUpdate }
    if ($checked.TerminalIcons) { Import-Module Terminal-Icons }
    if ($checked.Posh) { oh-my-posh init pwsh --config "$PSScriptRoot\Themes\zash_V2.omp.json" | Invoke-Expression }
    if ($checked.Starship -and !$checked.Posh) { & ([ScriptBlock]::Create((starship init powershell))) }

# import user functions
    . $PSScriptRoot\Scripts\powershell.functions.ps1

# import user aliases
    . $PSScriptRoot\Scripts\powershell.alias.ps1

# import user completions
    . $PSScriptRoot\Scripts\powershell.completion.ps1

# settings for psreadline
    $PSReadLine = @{
        EditMode = 'Windows'
        HistoryNoDuplicates = $true
        BellStyle = 'Visual'
        PredictionSource = 'History'
        PredictionViewStyle = 'InlineView'
    }
    Set-PSReadLineOption @PSReadLine