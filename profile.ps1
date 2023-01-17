# Check for installed software
$check = @{}
[void]$check.Add('Scoop',(Get-Command scoop).Path)
[void]$check.Add('ScoopCompletion',(Get-Module -ListAvailable -Name scoop-completion).Path)
[void]$check.Add('Posh',(Get-Command oh-my-posh).Path)
[void]$check.Add('Choco',(Get-Command choco).Path)
[void]$check.Add('Packwiz',(Get-Command packwiz).Path)
[void]$check.Add('PackwizCompletion',(Get-Module -ListAvailable -Name PackwizCompletion).Path)
[void]$check.Add('SpotifyTui',(Get-Command spt).Path)
[void]$check.Add('SpotifyTuiCompletion',(Get-Module -ListAvailable -Name SpotifyTuiCompletion).Path)
[void]$check.Add('RandomUtils',(Get-Module -ListAvailable -Name Random-Utils).Path)

$checked = @{}
foreach ($content in $check.GetEnumerator()) {
    if ($null -eq $content.Value) { [void]$checked.Add($content.Key,$false) }
    elseif ([System.IO.File]::Exists($content.Value)) { [void]$checked.Add($content.Key,$true) }
    else { [void]$checked.Add($content.Key,$false) }
}

# Set dependecies after check
if ($checked.Posh) { 
    oh-my-posh init pwsh --config "$env:USERPROFILE\Documents\Github\Pwsh\zash_V2.omp.json" | Invoke-Expression 
    Set-Alias -Name 'omp' -Value "oh-my-posh" -Description 'Oh-My-Posh short alias'
}
if ($checked.ScoopCompletion) { Import-Module scoop-completion }
if ($checked.Choco) { Import-Module “$env:ChocolateyInstall\helpers\chocolateyProfile.psm1” }
if ($checked.PackwizCompletion) { 
    Import-Module PackwizCompletion 
    Set-Alias -Name 'pw' -Value "packwiz" -Description 'Packwiz short alias'
}
if ($checked.SpotifyTuiCompletion) { Import-Module SpotifyTuiCompletion }
if ($checked.PSWindowsUpdate) {
    Set-Alias -Name 'gwu' -Value "Get-WindowsUpdate" -Description 'Get-WindowsUpdate short alias'
    Set-Alias -Name 'iwu' -Value "Install-WindowsUpdate" -Description 'Install-WindowsUpdate short alias'
}

# WinGet completion
Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
        [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
        $Local:word = $wordToComplete.Replace('"', '""')
        $Local:ast = $commandAst.ToString().Replace('"', '""')
        winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
}