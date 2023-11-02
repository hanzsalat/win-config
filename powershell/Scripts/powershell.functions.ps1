# reload powershell profile
    function Initialize-Powershell
    {
        switch ($PSVersionTable.PSVersion.Major) {
            7 { Invoke-Command { & pwsh } -NoNewScope }
            5 { Invoke-Command { & powershell } -NoNewScope }
            default { . $PROFILE.CurrentUserAllHosts }
        }
    }

# shutdown system
    function shutdown {
        shutdown.exe /s /t 0
    }

# reboot system
    function reboot {
        shutdown.exe /r /t 0
    }

# get all starup applications
    function Get-Startup 
    {
        Get-CimInstance Win32_StartupCommand |
        Select-Object Name,Command,Location,User |
        Format-List
    }   

# change host name of shell
    function Set-ShellName 
    {
        param (
            [parameter(Mandatory,Position = 0,ValueFromPipeline)]
            [string]$name
        )
        
        $Host.UI.RawUI.WindowTitle = $name
    }

# fix stuck glazewm
    function Repair-GlazeWM {
        if (Get-Process GlazeWM) {
            Get-Process GlazeWM | Stop-Process
        }
        Start-Process powershell -ArgumentList "glazewm --config=$env:USERPROFILE\.config\glazewm\config.yaml" -WindowStyle Hidden
    }

# list of advanced functions/scripts to import
    . $PSScriptRoot/glazewm.build.ps1
