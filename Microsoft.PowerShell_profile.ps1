# Init oh-my-posh with profile from git
oh-my-posh init pwsh --config 'C:\Users\Simon\Documents\GitHub\Oh-My-Posh-Profile\Custom-Profile.omp.json' | Invoke-Expression
# custom fucntions to speed up workflow
function Find-ChildItem {
    Param (
        [Parameter(Position=1)]
        [string]$name
    )

    process{
        Get-ChildItem | Where-Object {$_.Name -match "$name"}
    }
}
function Get-ItemCount {
    (Get-ChildItem).Count
}
New-Alias -Name 'fci' -Value "Find-ChildItem"
New-Alias -Name 'gic' -Value "Get-ItemCount" 