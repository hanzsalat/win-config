# reload the profile
    function Initialize-Profile {
        Remove-Item -Path $PSScriptRoot\..\checked.json
        & $profile.CurrentUserAllHosts
    }

# shutdown and reboot function
    function shutdown {
        shutdown.exe /s /t 0
    }
    function reboot {
        shutdown.exe /r /t 0
    }