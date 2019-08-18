Function Invoke-OOSMonitoring
{
    [CmdletBinding()]
    Param(
        [parameter(Mandatory=$true, HelpMessage="A PoShMonConfiguration instance - use New-PoShMonConfiguration to create it")]
        [hashtable]$PoShMonConfiguration
    )

    $outputValues = Invoke-MonitoringCore `
                        -PoShMonConfiguration $PoShMonConfiguration `
                        -TestList (Get-OOSTests) `
                        -FarmDiscoveryFunctionName 'Get-ServersInOOSFarm' `
                        -PlatformVersionDiscoveryFunctionName 'Get-OOSFarmVersion' `
                        -OutputOptimizationList @() #(Get-OOSResolutions) later when these get written one day...

    return $outputValues
}