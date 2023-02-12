function Server {
    param (
        [switch]$Start,
        [switch]$Stop,
        [switch]$Install
    )

    begin {
        # Check dependencies first
            if (Get-Dependencies @('ferium','scoop')) {
                Write-Verbose 'All needed programms are avaible on the system'
            } else { 
                Write-Error 'Missing some shit !'    
                break 
            }
    }

    process {
        # 
    }

    end {}

}
function Get-Dependencies {
    param (
        [Parameter(Mandatory)]$Names
    )

    $check = @{}
    foreach ($thing in $Names) {
        [void]$check.add($thing, (Get-Command -Name $thing -ErrorAction SilentlyContinue).Path)
    }
    $checked = @{}
    foreach ($item in $check.GetEnumerator()) {
        if ([System.IO.File]::Exists($item.Value)) { [void]$checked.Add($item.Key, $true) }
        else { [void]$checked.Add($item.Key, $false) }
    }
    $check
    $checked
    foreach ($item in $checked.GetEnumerator()) {
        if (!($item.Value)) {
            Write-Error "Missing $($item.Key) on system !"
            return $false >$null
        } 
        else { return $true >$null }
    }
}