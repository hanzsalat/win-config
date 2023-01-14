# Check for installed software
$check = @{
    Scoop = (Get-Command scoop).Path
    ScoopCompletion = "$($(Get-Item $(Get-Command scoop.ps1).Path).Directory.Parent.FullName)\modules\scoop-completion"
    Posh = (Get-Command oh-my-posh).Path
    Choco = (Get-Command choco).Path
    Packwiz = (Get-Command packwiz).Path
    PackwizCompletion = (Get-Module -ListAvailable -Name PackwizCompletion).Path
    SpotifyTui = (Get-Command spt).Path
    SpotifyTuiCompletion = (Get-Module -ListAvailable -Name SpotifyTuiCompletion).Path
}

$checked = @{}

foreach ($content in $check.GetEnumerator()) {
    if (Test-Path $content.Value) { $checked.Add($content.Key,$true) }
    else { $checked.Add($content.Key,$false) }
}

# Import modules
#$modules = Get-InstalledModule
#foreach ($module in $modules.Name) { Import-Module $module }

# Set dependecies after check
if ($checked.Posh) { 
    oh-my-posh init pwsh --config "$env:USERPROFILE\Documents\Github\Pwsh\zash_V2.omp.json" | Invoke-Expression 
    Set-Alias -Name 'omp' -Value "oh-my-posh" -Description 'Oh-My-Posh short alias'
}
if ($checked.ScoopCompletion -and $checked.Scoop) { Import-Module "$($(Get-Item $(Get-Command scoop.ps1).Path).Directory.Parent.FullName)\modules\scoop-completion" }
if ($checked.Choco) { Import-Module “$env:ChocolateyInstall\helpers\chocolateyProfile.psm1” }
if ($checked.PackwizCompletion -and $checked.Packwiz) { 
    Import-Module PackwizCompletion 
    Set-Alias -Name 'pw' -Value "packwiz" -Description 'Packwiz short alias'
}
if ($checked.SpotifyTuiCompletion -and $checked.SpotifyTui) { Import-Module SpotifyTuiCompletion }

# Quick access to navigate on system
$dwnld = $home + '\Downloads'
$dskt = $home + '\Desktop'
$doc = $home + '\Documents'
$git = $home + '\Documents\GitHub'

# Add/Change Aliases
Set-Alias -Name 'gwu' -Value "Get-WindowsUpdate" -Description 'Get-WindowsUpdate short alias'
Set-Alias -Name 'iwu' -Value "Install-WindowsUpdate" -Description 'Install-WindowsUpdate short alias'

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