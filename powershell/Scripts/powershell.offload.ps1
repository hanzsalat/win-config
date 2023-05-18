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