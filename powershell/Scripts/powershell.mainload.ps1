# load main components
    if ($checked.ChocoQAC) {Import-Module $env:ChocolateyInstall\helpers\chocolateyProfile.psm1 }
    if ($checked.OpQAC) { Import-Module OpCompletion }
    if ($checked.PackwizQAC) { Import-Module PackwizCompletion }
    if ($checked.ScoopQAC) { Import-Module scoop-completion }
    if ($checked.SpotifyTuiQAC) { Import-Module SpotifyTuiCompletion }
    if ($checked.PSWindowsUpdate) { Import-Module PSWindowsUpdate }
    if ($checked.TerminalIcons) { Import-Module Terminal-Icons }
    if ($checked.Posh) { oh-my-posh init pwsh --config $PSScriptRoot\..\Themes\zash_V2.omp.json | Invoke-Expression }
    if ($checked.Starship -and !$checked.Posh) { & ([ScriptBlock]::Create((starship init powershell))) }
