$ErrorActionPreference = 'SilentlyContinue'
$REPO_ROOT_PATH = (Get-item $PSScriptRoot).Parent.ResolvedTarget
$CONFIG_ROOT_PATH = Get-item $PSScriptRoot
$CONFIG_USER_PATH = "$env:USERPROFILE\.config"

<#
	.SYNOPSIS
		manifest file that holds onto all configuration informations
	.DESCRIPTION
		this files is used to push the config files where they belong
		and if some configs need a linkage to the path where the config should sit.
		also adds the use of options if there are more work enviorments for example,
		so its able to generate one config of more
	.NOTES
		for verioning ther is a script which will generate new versions for the
		manifest file based on ....
------------------
	.PARAMETER version
		holds the version of the config folder/latest changed function
	.PARAMETER name
		the name of the application which the config is for
	.PARAMETER description
		brief description of the config folder / latest changes
	.PARAMETER path
		path to the config folder where the content sits
	.PARAMETER target
		path to the target folder where the content belongs
------------------	
	.PARAMETER link
		holds the target for linking if an application is tricky to work with
		.PARAMETER folder
			path of the folder that should be linked
		.PARAMETER files
			path to files that should be linkes
------------------
	.PARAMETER userchoice
		a way to define more configuration enviorments / ore spcial use cases
		.PARAMETER question
			the questions that should be shown
		.PARAMETER target
			final target file name
		.PARAMETER options
			the options that should be shown
			.PARAMETER awnser
				holds the awnser for the question
			.PARAMETER path
				holds the path to the given awnser
#>

[PSCustomObject][ordered]@{
	version = "0.0.HHmm.MMddyy"
	name = "default"
	description = $null
	path = $null
	target = $null
	link = [PSCustomObject][ordered]@{
		folder = $null
		files = $null
	}
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
	version = "0.0.0.0"
	name = "GlazeWM"
	description = "include configuration files for my home and work config of glazewm"
	path = Resolve-Path "$CONFIG_ROOT_PATH\glazewm"
	target = "$CONFIG_USER_PATH\glazewm"
	link = $null
	userchoice = [PSCustomObject][ordered]@{
		question = "load which config ?"
		target = "config.yaml"
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
	target = [PSCustomObject][ordered]@{ 
		folder = "$CONFIG_USER_PATH\nvim"
	}
	link = "$env:LOCALAPPDATA\nvim"
	userchoice = $null
}
[PSCustomObject][ordered]@{
	version = "0.0.0.0"
	name = "Winfetch"
	description = "my winfetch configuration"
	path = Resolve-Path "$CONFIG_ROOT_PATH\winfetch"
	target = [PSCustomObject][ordered]@{
		folder = "$CONFIG_USER_PATH\winfetch"
	}
	link = $null
	userchoice = $null
}
[PSCustomObject][ordered]@{
	version = "0.0.0.0"
	name = "Windows Terminal"
	description = "include configuration files for my home and work config of the terminal"
	path = Resolve-Path "$CONFIG_ROOT_PATH\terminal"
	target = "$CONFIG_USER_PATH\terminal"
	link = [PSCustomObject][ordered]@{
		files = @(
			"$env:SCOOP_ROOT\persist\windows-terminal\settings.json"
			"$env:LocalAppData\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
		)
	}
	userchoice = [PSCustomObject]@{
		question = "load which config ?"
		target = "settings.json"
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
	target = [PSCustomObject][ordered]@{
		folder = "$CONFIG_USER_PATH\spotify-tui"
	}
	link = $null
	userchoice = $null
}
