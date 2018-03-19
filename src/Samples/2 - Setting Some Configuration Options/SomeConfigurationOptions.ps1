# Load the PoShMon module so that you can call it later
Import-Module PoShMon

$config = New-PoShMonConfiguration { }

Invoke-OSMonitoring -PoShMonConfiguration $config

$config = New-PoShMonConfiguration { OperatingSystem -FreeMemoryThresholdPercent 99 }

# this should fail in pretty much all cases, unless you -really- have more than 99 percent free memory
Invoke-OSMonitoring -PoShMonConfiguration $config -Verbose 

# this will only show the warning message, and no verbose output
Invoke-OSMonitoring -PoShMonConfiguration $config

# if you store the return value from the monitoring scan into a variable, you can use it later
# also, in this case, the only output you'll see on the screen is the warning
$scanOutput = Invoke-OSMonitoring -PoShMonConfiguration $config
