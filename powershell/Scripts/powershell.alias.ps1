if ($checked.Packwiz) {
    Set-Alias -Name pw -Value packwiz -Description 'Packwiz short term' 
}
if ($checked.Posh) {
    Set-Alias -Name omp -Value oh-my-posh -Description 'Oh-My-Posh short term' 
}
if ($checked.Winfetch) {
    Set-Alias -Name fetch -Value winfetch -Description 'Winfetch short term'
}
if ($checked.Helix) {
    Set-Alias -Name hx -Value helix -Description 'Helix short term'
}
if ($checked.Neovim) {
    Set-Alias -Name vim -Value nvim -Description 'Neovim short term' 
}
if (Get-Command -Name Initialize-Profile -ErrorAction SilentlyContinue) {
    Set-Alias -Name init -Value Initialize-Profile -Description 'Initialize-Profile short term'
}