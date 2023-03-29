#get $checked from powershell.check.ps1 script
    $checked = & $PSScriptRoot\powershell.check.ps1

# import modules after check
    if ($checked.ChocoCompletion) { Import-Module -Name "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1" }
    if ($checked.OpCompletion) { Import-Module OpCompletion }
    if ($checked.PackwizCompletion) { Import-Module PackwizCompletion }
    if ($checked.ScoopCompletion) { Import-Module scoop-completion }
    if ($checked.SpotifyTuiCompletion) { Import-Module SpotifyTuiCompletion }

# winget completion
    Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
        param($wordToComplete, $commandAst, $cursorPosition)
        [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
        $Local:word = $wordToComplete.Replace('"', '""')
        $Local:ast = $commandAst.ToString().Replace('"', '""')
        winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }