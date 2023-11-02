if ($checked.Packwiz.exists) {
    Set-Alias -Name pw -Value packwiz -Description 'Packwiz short term' 
}
if ($checked.Posh.exists) {
    Set-Alias -Name omp -Value oh-my-posh -Description 'Oh-My-Posh short term' 
}
if ($checked.Winfetch.exists) {
    Set-Alias -Name fetch -Value winfetch -Description 'Winfetch short term'
}
if ($checked.Helix.exists) {
    Set-Alias -Name hx -Value helix -Description 'Helix short term'
}
if ($checked.Neovim.exists) {
    Set-Alias -Name vim -Value nvim -Description 'Neovim short term' 
}

Set-Alias -Name init -Value Initialize-Powershell -Description 'Initialize-Powershell short term'
Set-Alias -Name initgw -Value Repair-GlazeWM -Description 'Reload GlazeWM when getting stuck'
Set-Alias -Name zip -Value Compress-Archive -Description 'easier command name to zip a file'
Set-Alias -Name unzip -Value Expand-Archive -Description 'easier command name to unzip a file'
Set-Alias -Name df -Value Get-Disk -Description 'report file system space usage'
