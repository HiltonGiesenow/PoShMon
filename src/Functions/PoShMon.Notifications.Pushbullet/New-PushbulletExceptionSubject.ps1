Function New-PushbulletExceptionSubject
{
    [CmdletBinding()]
    Param(
        [hashtable]$PoShMonConfiguration
    )

    return "[PoshMon $($PoShMonConfiguration.General.EnvironmentName) Monitoring]`r`n"
}