function Build-Manifest {
    param ($path)

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
        $version
    }
}

$path = (Get-Item $PSScriptRoot).Parent.Parent.FullName + '\.config\glazewm'
Build-Manifest -path $path
