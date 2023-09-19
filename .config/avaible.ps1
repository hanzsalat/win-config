$ErrorActionPreference = 'SilentlyContinue'
$REPO_ROOT_PATH = (Get-item $PSScriptRoot).Parent.ResolvedTarget
$CONFIG_ROOT_PATH = Get-item $PSScriptRoot
$CONFIG_USER_PATH = $env:USERPROFILE + '\.config'

[PSCustomObject]@{
	name = "default"
	description = $null
	path = Resolve-Path "$CONFIG_ROOT_PATH"
	link = [PSCustomObject]@{
		path = $null
	}
	target = $null
	userchoice = [PSCustomObject]@{
		question = $null
		options = @(
			[PSCustomObject]@{
				awnser = $null
				path = $null
			}
		)
		target = $null
	}
}
[PSCustomObject]@{
	name = "glazewm"
	description = "include configuration files for my home and work config of glazewm"
	path = Resolve-Path "$CONFIG_ROOT_PATH\glazewm"
	link = $null
	target = "$CONFIG_USER_PATH\glazewm"
	userchoice = [PSCustomObject]@{
		question = "load which config ?"
		options = @(
			[PSCustomObject]@{
				awnser = "home"
				path = "$CONFIG_ROOT_PATH\glazewm\home.yaml"
			}
			[PSCustomObject]@{
				awnser = "work"
				path = "$CONFIG_ROOT_PATH\glazewm\work.yaml"
			}
		)
		target = "$CONFIG_USER_PATH\glazewm\config.yaml"
	}
}
[PSCustomObject]@{
	name = "nvim"
	description = "my nvim configuration"
	path = Resolve-Path "$CONFIG_ROOT_PATH\nvim"
	link = [PSCustomObject]@{
		path = "$env:LOCALAPPDATA\nvim"
	}
	target = "$CONFIG_USER_PATH\nvim"
	userchoice = $null
}
[PSCustomObject]@{
	name = "winfetch"
	description = "my winfetch configuration"
	path = Resolve-Path "$CONFIG_ROOT_PATH\winfetch"
	link = $null
	target = "$CONFIG_USER_PATH\winfetch"
	userchoice = $null
}
[PSCustomObject]@{
	name = "terminal"
	description = "include configuration files for my home and work config of the terminal"
	path = Resolve-Path "$CONFIG_ROOT_PATH\terminal"
	link = [PSCustomObject]@{
		path = @(
			"$env:SCOOP_ROOT\persist\windows-terminal"
			"$env:LocalAppData\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
		)
	}
	target = "$CONFIG_USER_PATH\terminal"
	userchoice = [PSCustomObject]@{
		question = "load which config ?"
		options = @(
			[PSCustomObject]@{
				awnser = "home"
				path = "$CONFIG_ROOT_PATH\terminal\home.json"
			}
			[PSCustomObject]@{
				awner = "work"
				path = "$CONFIG_ROOT_PATH\terminal\work.json"
			}
		)
		target = "$CONFIG_USER_PATH\terminal\settings.json"
	}
}
[PSCustomObject]@{
	name = "Spotify-TUI"
	description = "my spt configuration"
	path = Resolve-Path "$CONFIG_ROOT_PATH\spt"
	link = $null
	target = "$CONFIG_USER_PATH\spotify-tui"
	userchoice = $null
}
