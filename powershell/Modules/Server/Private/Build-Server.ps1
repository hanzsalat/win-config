#Requires -Version 5.1
function build {
    param(
        [Parameter(Mandatory)][int]$modpackid
    )

    begin {
        # Hashtable with all used paths for the script
        $path = @{
            SelectedDir = Get-UserInput -Path
            FeriumConfig = $($env:USERPROFILE + '\.config\ferium\config.json')
            FeriumTmp = $($env:USERPROFILE + '\.config\ferium\.tmp\')
        }
        # check if modpack already exists in ferium and exit
        if ($(ferium modpack list) -match $modpackid) {
            Write-Warning 'Modpack already exists in ferium !'
            exit
        }
    }

    process {
        # adding the modpack to ferium
        ferium modpack add $modpackid --output-dir $path.SelectedDir --install-overrides true
        # Get the Modpack Name out of the ferium config
        $feriumConfig = Get-Content $path.FeriumConfig | ConvertFrom-Json
        $modpackName = ($feriumConfig.modpacks | Where-Object -Match -Property 'identifier' -Value "..*=$modpackid}").name
        # Set the current modpack in ferium just to be double safe
        ferium modpack switch --modpack-name $modpackName
        # install modpack
        $output = Get-ProcessOutput -FileName 'ferium.exe' -Arguments 'modpack upgrade' -Verbose
        # check for 3rd Partie mods and download them
        if ($output.StandardError.Length -gt 0) {
            $output.StandardError -split "\n" | 
            Where-Object {$_ -match 'https'} | 
            ForEach-Object {
                $url = $_ -replace ('\s','')
                Start-Process $url
                # ! need a change up
                $Listen = & .\libraries\Modules\Read-DownloadsFolder.ps1
                Move-Item -Path ($env:USERPROFILE + '\Downloads\' + $Listen.name) -Destination ($path.SelectedDir + '\mods') -Verbose
            }
            Start-Sleep 1
        }
        # Get the downloaded manifest file
        $modpackManifest = Get-Content ($path.FeriumTmp + $modpackName + '\manifest.json') | ConvertFrom-Json
        # Get the modloader name & version
        $modloader = $modpackmanifest.minecraft.modloaders.id -split '-'
        $modloadername = $modloader[0]
        $modloaderversion = $modloader[1]
        # Get the minecraft version
        $minecraftVersion = $modpackmanifest.minecraft.version
        # ! from here all things need to be worked up bruhh -.-
        # download and install modloader needed for modpack
        switch ($modloadername) {
            forge {
                # download link for the forge-instlller.jar
                $forgeurl = "https://maven.minecraftforge.net/net/minecraftforge/forge/$minecraftversion-$modloaderversion/forge-$minecraftversion-$modloaderversion-installer.jar"
                # direction + name of the installer to download
                $filename = $path.SelectedDir + "\forge-$minecraftversion-$modloaderversion-installer.jar"
                if (!(Test-Path -Path $filename)) { Invoke-WebRequest -Uri $forgeurl -OutFile $filename }
                while (!(Test-Path $filename)) { Start-Sleep 1 }
                if (!(Test-Path -Path ($path.SelectedDIR + '\run.bat'))) {
                    Set-Location -Path $path.SelectedDir
                    java -jar $filename --installServer
                    # ! put no gui into the run.bat and generate eula.txt
                    New-Item .\eula.txt | Set-Content -Value 'eula=true'
                    $old = Get-Content .\run.bat | Where-Object {$_ -match 'java'}
                    $new = $old + ' nogui'
                    (Get-Content .\run.bat).Replace($old,$new) | Set-Content .\run.bat
                    Set-Content .\user_jvm_args.txt -Value '-Xmx4G -Xms2G'
                    Set-Location -Path $PSScriptRoot
                }
            }
            fabric {
                # ! Same shit here :%
            }
        }
    }

    end {}
}