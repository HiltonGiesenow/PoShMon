Function Invoke-SPMonitoring
{
    [CmdletBinding()]
    Param(
        [parameter(Mandatory=$true, HelpMessage="A PoShMonConfiguration instance - use New-PoShMonConfiguration to create it")]
        [hashtable]$PoShMonConfiguration
    )

    if ($PoShMonConfiguration.SharePoint -eq $null) { $PoShMonConfiguration.SharePoint = SharePoint }

    $outputValues = Invoke-MonitoringCore `
                        -PoShMonConfiguration $PoShMonConfiguration `
                        -TestList (Get-SPTests) `
                        -FarmDiscoveryFunctionName 'Get-ServersInSPFarm' `
                        -OutputOptimizationList (Get-SPResolutions) `
                        -MergesList (Get-SPMerges)

    return $outputValues
}