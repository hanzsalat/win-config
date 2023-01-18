# Check for installed software
$check = @{}
# Sofware
[void]$check.Add('Choco', (Get-Command choco -ErrorAction Ignore).Path)
[void]$check.Add('Packwiz', (Get-Command packwiz -ErrorAction Ignore).Path)
[void]$check.Add('Posh', (Get-Command oh-my-posh -ErrorAction Ignore).Path)
[void]$check.Add('PSWindowsUpdate', (Get-Module -ListAvailable -Name PSWindowsUpdate).Path)
[void]$check.Add('RandomUtils', (Get-Module -ListAvailable -Name Random-Utils).Path)
[void]$check.Add('Scoop', (Get-Command scoop -ErrorAction Ignore).Path)
[void]$check.Add('SpotifyTui', (Get-Command spt -ErrorAction Ignore).Path)
# Completion
[void]$check.Add('ChocoCompletion', "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1")
[void]$check.Add('OpCompletion', (Get-Module -ListAvailable -Name OpCompletion).Path)
[void]$check.Add('PackwizCompletion', (Get-Module -ListAvailable -Name PackwizCompletion).Path)
[void]$check.Add('ScoopCompletion', (Get-Module -ListAvailable -Name scoop-completion).Path)
[void]$check.Add('SpotifyTuiCompletion', (Get-Module -ListAvailable -Name SpotifyTuiCompletion).Path)

$checked = @{}
foreach ($content in $check.GetEnumerator()) {
    if ($null -eq $content.Value) { [void]$checked.Add($content.Key, $false) }
    elseif ([System.IO.File]::Exists($content.Value)) { [void]$checked.Add($content.Key, $true) }
    else { [void]$checked.Add($content.Key, $false) }
}

# Set dependecies after check
# Software
if ($checked.Packwiz) { Set-Alias -Name 'pw' -Value "packwiz" -Description 'Packwiz short alias' }
if ($checked.Posh) { 
    oh-my-posh init pwsh --config "$env:USERPROFILE\Documents\Github\Pwsh\zash_V2.omp.json" | Invoke-Expression 
    Set-Alias -Name 'omp' -Value "oh-my-posh" -Description 'Oh-My-Posh short alias'
}
if ($checked.PSWindowsUpdate) {
    Set-Alias -Name 'gwu' -Value "Get-WindowsUpdate" -Description 'Get-WindowsUpdate short alias'
    Set-Alias -Name 'iwu' -Value "Install-WindowsUpdate" -Description 'Install-WindowsUpdate short alias'
}
# Completion
if ($checked.ChocoCompletion) { Import-Module $check.ChocoCompletion }
if ($checked.OpCompletion) { Import-Module OpCompletion }
if ($checked.PackwizCompletion) { Import-Module PackwizCompletion }
if ($checked.ScoopCompletion) { Import-Module scoop-completion }
if ($checked.SpotifyTuiCompletion) { Import-Module SpotifyTuiCompletion }

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