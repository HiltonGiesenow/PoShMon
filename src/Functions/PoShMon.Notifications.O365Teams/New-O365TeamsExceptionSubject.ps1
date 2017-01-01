Function New-O365TeamsExceptionSubject
{
    [CmdletBinding()]
    Param(
        [hashtable]$PoShMonConfiguration
    )

    return "[PoshMon $($PoShMonConfiguration.General.EnvironmentName) Monitoring]`r`n"
}