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
        $null = Get-Command git -CommandType Application -ErrorAction Stop
        $null = Resolve-Path ($env:USERPROFILE + '/github/GlazeWM') -ErrorAction Stop
        $oldPath = $PWD
        $projectFile = "$Path\GlazeWM.App\GlazeWM.App.csproj"
    }

    process {
        Get-Process glazewm -ErrorAction Ignore | Stop-Process
        Set-Location $Path
        git pull
        dotnet publish $projectFile --configuration=Release --runtime=win-x64 --output=$Destination --self-contained -p:PublishSingleFile=true -p:IncludeAllContentForSelfExtract=true
        Set-Location $oldPath
        Start-Process powershell -ArgumentList "glazewm --config=$env:USERPROFILE\.config\glazewm\config.yaml" -WindowStyle Hidden
    }
}
