# reload powershell profile
    function Initialize-Profile {
        & $profile.CurrentUserAllHosts
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
    function Get-Startup {
        Get-CimInstance Win32_StartupCommand |
        Select-Object Name,Command,Location,User |
        Format-List
    }   

# list of advanced functions/scripts to import
    . $PSScriptRoot/glazewm.build.ps1
