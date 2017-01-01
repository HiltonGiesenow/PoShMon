Function New-EmailExceptionSubject
{
    [CmdletBinding()]
    Param(
        [hashtable]$PoShMonConfiguration
    )

    return "[PoshMon] $($PoShMonConfiguration.General.EnvironmentName) Monitoring - Exception Occurred"
}