Function Invoke-OSMonitoring
{
    [CmdletBinding()]
    Param(
        [parameter(Mandatory=$true, HelpMessage="A PoShMonConfiguration instance - use New-PoShMonConfiguration to create it")]
        [hashtable]$PoShMonConfiguration
    )

    $outputValues = Invoke-MonitoringCore -PoShMonConfiguration $PoShMonConfiguration -TestList (Get-OSTests)

    return $outputValues
}