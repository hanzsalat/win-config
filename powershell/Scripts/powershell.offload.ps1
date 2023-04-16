# set komorebi enviorment variable to put config files into .config
    if ($checked.Komorebi) { $Env:KOMOREBI_CONFIG_HOME = "$env:USERPROFILE\.config\komorebi" }

# settings for psreadline
    $PSReadLine = @{
        EditMode = 'Windows'
        HistoryNoDuplicates = $true
        BellStyle = 'Visual'
        PredictionSource = 'History'
        PredictionViewStyle = 'InlineView'
    }
    Set-PSReadLineOption @PSReadLine
    $null = $PSReadLine

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