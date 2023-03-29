function Get-UserInput {
    [CmdletBinding()]
    param (
        [switch]$Decision,
        [switch]$Path,
        [string]$Title, 
        [string]$Message,
        [int]$Default = 0,
        $Options,
        $RetrunValues
    )

    process {
        if ($Decision) {
            $opt = New-Object System.Collections.ArrayList
            foreach ($option in $Options) {
                switch ($option.GetType().Name) {
                    Hashtable {
                        foreach ($key in $option.Keys) {
                            $opt.add((New-Object System.Management.Automation.Host.ChoiceDescription "$('&' + "$key")","$($option[$key])")) | Out-Null
                        }
                    }
                    String {
                        $opt.add((New-Object System.Management.Automation.Host.ChoiceDescription "$option",$null)) | Out-Null
                    }
                }
            }
            $choices = [System.Management.Automation.Host.ChoiceDescription[]] $opt
            $answer = $Host.UI.PromptForChoice($Title, $Message, $choices, $Default)
            if ($null -ne $RetrunValues) { return $RetrunValues[$choices.Label[$answer] -replace '&',''] }
            else { return $choices.Label[$answer] }
        } elseif ($Path) {
            Add-Type -AssemblyName System.Windows.Forms
            $browser = New-Object System.Windows.Forms.FolderBrowserDialog
            $null = $browser.ShowDialog()
            return $browser.SelectedPath
        } else {
            break   
        }
    }   
}