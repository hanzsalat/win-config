Using Namespace System
Using Namespace System.IO

function Build-GlazeWM {
    param(
        [Parameter(Position = 0)]
        [string]$Path = "$env:USERPROFILE\github\GlazeWM",
        [Parameter(Position = 1)]
        [string]$Destination = "$env:USERPROFILE\dotnet"
    )

    begin {
        [void](Get-Command git -CommandType Application -ErrorAction Stop)
        $repo = Test-Path "$env:USERPROFILE/github/GlazeWM"
        $sdk = dotnet --list-sdks | ForEach-Object {$PSItem -match '7'}
        $oldPath = $PWD
        $projectFile = "$Path\GlazeWM.App\GlazeWM.App.csproj"
    }

    process {
        
        if (!$repo) {
            Set-Location "$env:USERPROFILE\github"
            git clone https://github.com/glazerdesktop/GlazeWM.git
        }
        if (!$sdk) { Write-Error "missing right dotnet sdk version" }
        Set-Location $Path
        $status = git pull
        if (!($status -match 'up to date')) {
            Get-Process glazewm -ErrorAction Ignore | Stop-Process
            dotnet publish $projectFile --configuration=Release --runtime=win-x64 --output=$Destination --self-contained -p:PublishSingleFile=true -p:IncludeAllContentForSelfExtract=true
            Start-Process powershell -ArgumentList "glazewm --config=$env:USERPROFILE\.config\glazewm\config.yaml" -WindowStyle Hidden
        }
        else {
            Write-Warning 'repo/build up to date'
        }
        Set-Location $oldPath
    }
}
