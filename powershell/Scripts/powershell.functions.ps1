function Initialize-Profile {
    [void](Remove-Item -Path $PSScriptRoot\..\Locals\checked.json -Force)
    & $profile.CurrentUserAllHosts
}

function shutdown {
    shutdown.exe /s /t 0
}

function reboot {
    shutdown.exe /r /t 0
}