Function New-O365TeamsMessageSubject
{
    [CmdletBinding()]
    Param(
        [hashtable]$PoShMonConfiguration,
        [object[]]$TestOutputValues
    )

    return "[$($PoShMonConfiguration.General.EnvironmentName) Monitoring Report]`r`n"
}