$REPO_ROOT_PATH = (Get-item $PSScriptRoot).Parent.ResolvedTarget
$CONFIG_ROOT_PATH = Get-item $PSScriptRoot

@{
	default = @{
		avaible = $null
		path = Resolve-Path($CONFIG_ROOT_PATH)
		link = @{
			needed = $null
			path = $null
		}
		userchoice = @{
			needed = $null
			question = $null
			options = @()
		}
	}
	glazewm = @{
		avaible = $true
		path = Resolve-Path($CONFIG_ROOT_PATH + '/glazewm')
		link = @{
			needed = $null
			path = $null
		}
		userchoice = @{
			needed = $true
			question = ""
			options = @()
		}
	}
}