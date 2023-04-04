# set aliases after check
    if ($checked.Packwiz) { Set-Alias -Name 'pw' -Value 'packwiz' -Description 'Packwiz short alias' }
    if ($checked.Posh) { Set-Alias -Name 'omp' -Value 'oh-my-posh' -Description 'Oh-My-Posh short term' }
    if ($checked.Winfetch) { Set-Alias -Name 'fetch' -Value 'winfetch' -Description 'Winfetch short alias' }