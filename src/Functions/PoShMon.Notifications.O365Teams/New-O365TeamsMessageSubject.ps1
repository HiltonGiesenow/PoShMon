Function New-O365TeamsMessageSubject
{
    [CmdletBinding()]
    Param(
        [hashtable]$PoShMonConfiguration,
        [System.Collections.ArrayList]$TestOutputValues
    )

    return "[$($PoShMonConfiguration.General.EnvironmentName) Monitoring Report]`r`n"
}