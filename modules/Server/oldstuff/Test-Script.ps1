Import-Module -Name .\Build-Server.ps1 -Force
build -modpackid 519787
if ($(Show-Menu @('Yes','No')) -eq 'Yes') {
    ferium modpack delete --modpack-name 'Create+ [Forge]'
} else { exit }