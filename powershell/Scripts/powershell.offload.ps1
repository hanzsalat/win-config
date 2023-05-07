# settings for psreadline
    if ($PSVersionTable.PSVersion.Major -eq 7) {
        $PSReadLine = @{
            EditMode = 'Windows'
            HistoryNoDuplicates = $true
            BellStyle = 'Visual'
            PredictionSource = 'HistoryAndPlugin'
            PredictionViewStyle = 'InlineView'
        }
        Set-PSReadLineOption @PSReadLine
    }
    if ($PSVersionTable.PSVersion.Major -eq 5) {
        $PSReadLine = @{
            EditMode = 'Windows'
            HistoryNoDuplicates = $true
            BellStyle = 'Visual'
        }
        Set-PSReadLineOption @PSReadLine
    }

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