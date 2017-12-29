Function New-HtmlExceptionSubject
{
    [CmdletBinding()]
    Param(
        [hashtable]$PoShMonConfiguration,
        [ValidateSet("Monitoring", "Repairing")]
        [string]$Action = "Monitoring"
    )

    return "[PoshMon] $($PoShMonConfiguration.General.EnvironmentName) $Action - Exception Occurred"
}