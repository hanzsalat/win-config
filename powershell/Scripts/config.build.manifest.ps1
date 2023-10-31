function Build-Manifest {
    <#
    .SYNOPSIS
        Builds the manifest file for .config folder of win-config repo
    .LINK
        https://github.com/hanzsalat/win-config/
    .DESCRIPTION
        Atm 
    #>

    param (
        [string]$path,
        [Alias("GV")]
        [switch]${generate-versions}
    )

    begin {
        $paths = Get-ChildItem $path
        $lastwriteTime = $paths | ForEach-Object { Get-ChildItem $PSItem -Depth 10 } | Select-Object LastWriteTime | Sort-Object date -Descending
        $revision = $lastwriteTime[0].LastWriteTime.ToString("Hms")
        $build = $lastwriteTime[0].LastWriteTime.ToString("Md")
        $major = 0
        $minor = 1
        $version = [version]::new($major,$minor,$build,$revision)
    }

    process {
        
    }
}
