Using namespace System.IO

$commands = Get-Command -CommandType Application
$modules  = Get-Module -ListAvailable
$checked = New-Object System.Collections.ArrayList

$list = @(
    [PSCustomObject]@{ 
        Name = 'GlazeWM'
        Pattern = 'glazewm.exe'
        Type = 'Command'
    }
    [PSCustomObject]@{ 
        Name = 'Komorebi'
        Pattern = 'komorebi.exe'
        Type = 'Command'
    }
    [PSCustomObject]@{ 
        Name = 'Nircmd'
        Pattern = 'nircmd.exe'
        Type = 'Command'
    }
    [PSCustomObject]@{ 
        Name = 'Packwiz'
        Pattern = 'packwiz.exe'
        Type = 'Command'
    }
    [PSCustomObject]@{ 
        Name = 'Posh'
        Pattern = 'oh-my-posh.exe'
        Type = 'Command'
    }
    [PSCustomObject]@{ 
        Name = 'Scoop'
        Pattern = 'scoop.cmd'
        Type = 'Command'
    }
    [PSCustomObject]@{ 
        Name = 'Spotify-Tui'
        Pattern = 'spt.exe'
        Type = 'Command'
    }
    [PSCustomObject]@{ 
        Name = 'Starship'
        Pattern = 'starship.exe'
        Type = 'Command'
    }
    [PSCustomObject]@{ 
        Name = 'Winfetch'
        Pattern = 'winfetch.cmd'
        Type = 'Command'
    }
    [PSCustomObject]@{ 
        Name = 'Pwsh'
        Pattern = 'pwsh.exe'
        Type = 'Command'
    }
    [PSCustomObject]@{ 
        Name = 'Neovim'
        Pattern = 'nvim.exe'
        Type = 'Command'
    }
    [PSCustomObject]@{ 
        Name = 'Helix'
        Pattern = 'helix.exe'
        Type = 'Command'
    }
    [PSCustomObject]@{ 
        Name = 'VSCode'
        Pattern = 'code.cmd'
        Type = 'Command'
    }
    [PSCustomObject]@{ 
        Name = 'WinGet'
        Pattern = 'winget.exe'
        Type = 'Command'
    }
    [PSCustomObject]@{ 
        Name = 'Whkd'
        Pattern = 'whkd.exe'
        Type = 'Command'
    }
    [PSCustomObject]@{ 
        Name = 'WindwosTerminal'
        Pattern = 'wt.exe'
        Type = 'Command'
    }
    [PSCustomObject]@{ 
        Name = '1PasswordCLI'
        Pattern = 'op.exe'
        Type = 'Command'
    }
    [PSCustomObject]@{
        Name = 'Sfsu'
        Pattern = 'sfsu.exe'
        Type = 'Command'
    }
    [PSCustomObject]@{ 
        Name = 'Z'
        Pattern = 'z'
        Type = 'Module'
    }
    [PSCustomObject]@{ 
        Name = 'PSReadLine'
        Pattern = 'psreadline'
        Type = 'Module'
    }
    [PSCustomObject]@{ 
        Name = 'Terminal-Icons'
        Pattern = 'terminal-icons'
        Type = 'Module'
    }
    [PSCustomObject]@{ 
        Name = 'Scoop-Completion'
        Pattern = 'scoop-completion'
        Type = 'Module'
    }
)

$checked = foreach ($item in $list) {
    @{
        $item.Name = [PSCustomObject]@{
            data = switch ($item.Type) {
                Command { $commands.Where({ $PSItem.Name -contains $item.Pattern }) }
                Module { $modules.Where({ $PSItem.Name -contains $item.Pattern }) }
                Default {}
            }
            exists = switch ($item.Type) {
                Command { 
                    if ([File]::Exists(($commands.Where({ $PSItem.Name -contains $item.Pattern }).Path | Select-Object -First 1))) 
                    { $true }
                    else 
                    { $false }
                }
                Module { 
                    if ([File]::Exists(($modules.Where({ $PSItem.Name -contains $item.Pattern }).Path | Select-Object -First 1))) 
                    { $true }
                    else 
                    { $false }
                }
                Default {}
            }
        }
    }
}

return $checked
