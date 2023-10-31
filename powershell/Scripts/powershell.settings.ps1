if ($checked.PSReadLine.exists) {
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
}

if ($checked.Sfsu) {
    #Invoke-Expression (&sfsu hook)
}

if (Test-Path $env:OneDriveConsumer -ErrorAction Ignore) {
    Set-Variable -Name onedrive -Value $env:OneDriveConsumer
}

if (Test-Path $env:OneDriveCommercial -ErrorAction Ignore) {
    Set-Variable -Name tesla -Value $env:OneDriveCommercial
}

if (Test-Path "$env:USERPROFILE\github" -ErrorAction Ignore) {
    $script:tmp = New-Object hashtable
    Get-ChildItem "$env:USERPROFILE\github" | ForEach-Object {[void]$tmp.Add($PSItem.BaseName,$PSItem.FullName)}
    Set-Variable -Name git -Value $tmp
}
