Get-ChildItem "$(Split-Path $script:MyInvocation.MyCommand.Path)\Public\*" -Filter '*.ps1' -Recurse | ForEach-Object { 
    . $_.FullName 
} 