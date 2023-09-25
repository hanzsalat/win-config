$ErrorActionPreference = 'SilentlyContinue'
$REPO_ROOT_PATH = (Get-item $PSScriptRoot).Parent.ResolvedTarget
$CONFIG_ROOT_PATH = Get-item $PSScriptRoot
$CONFIG_USER_PATH = $env:USERPROFILE + '\.config'

[PSCustomObject][ordered]@{
	version = "0.0.HHmm.MMddyy"
	name = "default"
	description = $null
	path = Resolve-Path "$CONFIG_ROOT_PATH"
	target = $null
	link = $null
	userchoice = [PSCustomObject][ordered]@{
		question = $null
		target = $null
		options = @(
			[PSCustomObject][ordered]@{
				awnser = $null
				path = $null
			}
		)
	}
}
[PSCustomObject][ordered]@{
	version = "0.1.0.0"
	name = "GlazeWM"
	description = "include configuration files for my home and work config of glazewm"
	path = Resolve-Path "$CONFIG_ROOT_PATH\glazewm"
	target = "$CONFIG_USER_PATH\glazewm"
	link = $null
	userchoice = [PSCustomObject][ordered]@{
		question = "load which config ?"
		target = "$CONFIG_USER_PATH\glazewm\config.yaml"
		options = @(
			[PSCustomObject][ordered]@{
				awnser = "home"
				path = "$CONFIG_ROOT_PATH\glazewm\home.yaml"
			}
			[PSCustomObject][ordered]@{
				awnser = "work"
				path = "$CONFIG_ROOT_PATH\glazewm\work.yaml"
			}
		)
	}
}
[PSCustomObject][ordered]@{
	version = "0.0.0.0"
	name = "Neovim"
	description = "my nvim configuration"
	path = Resolve-Path "$CONFIG_ROOT_PATH\nvim"
	target = "$CONFIG_USER_PATH\nvim"
	link = "$env:LOCALAPPDATA\nvim"
	userchoice = $null
}
[PSCustomObject][ordered]@{
	version = "0.0.0.0"
	name = "Winfetch"
	description = "my winfetch configuration"
	path = Resolve-Path "$CONFIG_ROOT_PATH\winfetch"
	target = "$CONFIG_USER_PATH\winfetch"
	link = $null
	userchoice = $null
}
[PSCustomObject][ordered]@{
	version = "0.0.0.0"
	name = "Windows Terminal"
	description = "include configuration files for my home and work config of the terminal"
	path = Resolve-Path "$CONFIG_ROOT_PATH\terminal"
	target = "$CONFIG_USER_PATH\terminal"
	link = @(
		"$env:SCOOP_ROOT\persist\windows-terminal"
		"$env:LocalAppData\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
	)
	userchoice = [PSCustomObject]@{
		question = "load which config ?"
		target = "$CONFIG_USER_PATH\terminal\settings.json"
		options = @(
			[PSCustomObject][ordered]@{
				awnser = "home"
				path = "$CONFIG_ROOT_PATH\terminal\home.json"
			}
			[PSCustomObject][ordered]@{
				awnser = "work"
				path = "$CONFIG_ROOT_PATH\terminal\work.json"
			}
		)
	}
}
[PSCustomObject][ordered]@{
	version = "0.0.0.0"
	name = "Spotify-TUI"
	description = "my spt configuration"
	path = Resolve-Path "$CONFIG_ROOT_PATH\spt"
	target = "$CONFIG_USER_PATH\spotify-tui"
	link = $null
	userchoice = $null
}
