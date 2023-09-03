# general
    Using namespace System.IO
    $ErrorActionPreference = 'Stop'

# scriptblocks
    $exists = {
        param([switch]$scoop,$winget)
        if ($null -ne (Get-Command scoop -CommandType Application) -and $scoop) { $true }
        elseif ($null -ne (Get-Command winget -CommandType Application) -and $winget) { $true }
        else { $false }
    }

    $check = {
        param([switch]$scoop,$winget)
        if ($null -ne (Get-Command scoop -CommandType Application) -and $scoop) { scoop list }
        elseif ($null -ne (Get-Command winget -CommandType Application) -and $winget) { winget list }
        else { $null }
    }

    $scoop = {
        if (!$data.scoop.exists) {
            Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
            Invoke-RestMethod get.scoop.sh | Invoke-Expression
            scoop install main/git
        }
        $avaiabelBuckets = scoop bucket list
        $diff = Compare-Object -ReferenceObject $data.scoop.buckets -DifferenceObject $avaiabelBuckets.name |
        Where-Object { $PSItem.SideIndicator -eq '<=' } |
        Select-Object InputObject
        foreach ($item in $diff) {
            scoop bucket add $item.InputObject
        }
        foreach ($item in $data.scoop.list.GetEnumerator()) {
            foreach ($thing in $item.Value) { & $program -name $thing -bucket $item.Key -scoop }
        }
    }

    $winget = {

    }

    $program = {
        param([switch]$scoop,$winget,[psobject]$name,$bucket,$id)
        if ($scoop) {
            $install = $bucket + '/' + $name
            if ($data.scoop.checked.Name -notcontains $name) {
                if ($bucket -match 'nonportable') { gsudo scoop install $install }
                else { scoop install $install }
            }
            else { Write-Output "'$name' is already installed" }
        }
    }

# data
    $data = @{
        scoop = @{
            exists = & $exists -scoop
            checked = & $check -scoop
            buckets = @('extras','nonportable','versions','nerd-fonts')
            list = @{
                main = @('1password-cli','7zip','bottom','gsudo','neovim','nircmd','oh-my-posh','pwsh','spotify-tui','winfetch')
                extras = @('discord','firefox','gimp','obsidian','powertoys','psreadline','scoop-completion','spotify','terminal-icons','vscode','windows-terminal','z')
                nirsoft = @('winlister')
                nonportable = @('equalizer-apo-np','nvidia-display-driver-dch-np')
            }
        }
        winget = @{

        }
    }

# script
    & $scoop
