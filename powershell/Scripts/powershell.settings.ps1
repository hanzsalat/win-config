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

Set-Variable -Name onedrive -Value $env:OneDriveConsumer
Set-Variable -Name tesla -Value $env:OneDriveCommercial