#### Disable nvidia panel to get rid of telemetry
> Stop-Service NVDisplay.ContainerLocalSystem

> Set-Service NVDisplay.ContainerLocalSystem -StartupType Disabled

#### Enable it back on
> Set-Service NVDisplay.ContainerLocalSystem -StartupType Automatic

> Start-Service NVDisplay.ContainerLocalSystem