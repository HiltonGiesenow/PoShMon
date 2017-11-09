Function Invoke-OSMonitoring
{
    [CmdletBinding()]
    Param(
        [parameter(HelpMessage="A PoShMonConfiguration instance - use New-PoShMonConfiguration to create it")]
        [hashtable]$PoShMonConfiguration
    )

    $outputValues = Invoke-MonitoringCore `
                        -PoShMonConfiguration $PoShMonConfiguration `
                        -TestList (Get-OSTests) `
                        -MergesList (Get-OSMerges)

    return $outputValues
}