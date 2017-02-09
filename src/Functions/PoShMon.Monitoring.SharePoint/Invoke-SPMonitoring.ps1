Function Invoke-SPMonitoring
{
    [CmdletBinding()]
    Param(
        [parameter(Mandatory=$true, HelpMessage="A PoShMonConfiguration instance - use New-PoShMonConfiguration to create it")]
        [hashtable]$PoShMonConfiguration
    )

    $outputValues = Invoke-MonitoringCore `
                        -PoShMonConfiguration $PoShMonConfiguration `
                        -TestList (Get-SPTests) `
                        -FarmDiscoveryFunctionName 'Get-ServersInSPFarm' `
                        -OutputOptimizationList (Get-SPResolutions)

    return $outputValues
}