# Load the PoShMon module so that you can call it later
Import-Module PoShMon

Invoke-OSMonitoring

Invoke-OSMonitoring -Verbose # Use the 'Verbose' switch to show the detailed scan output
