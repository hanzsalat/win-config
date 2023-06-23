function Initialize-Profile {
    & $profile.CurrentUserAllHosts
}

function shutdown {
    shutdown.exe /s /t 0
}

function reboot {
    shutdown.exe /r /t 0
}