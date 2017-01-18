Function Invoke-OSMonitoring
{
    [CmdletBinding()]
    Param(
        [parameter(Mandatory=$true, HelpMessage="A PoShMonConfiguration instance - use New-PoShMonConfiguration to create it")]
        [hashtable]$PoShMonConfiguration
    )

    if ($PoShMonConfiguration.TypeName -ne 'PoShMon.Configuration')
        { throw "PoShMonConfiguration is not of the correct type - please use New-PoShMonConfiguration to create it" }

    $stopWatch = [System.Diagnostics.Stopwatch]::StartNew()

    $testsToRun = Get-FinalTestsToRun -AllTests (Get-OSTests) -PoShMonConfiguration $PoShMonConfiguration
    $outputValues = Invoke-Tests $testsToRun -PoShMonConfiguration $PoShMonConfiguration

    $stopWatch.Stop()

    Process-Notifications -PoShMonConfiguration $PoShMonConfiguration -TestOutputValues $outputValues -TotalElapsedTime $stopWatch.Elapsed

    return $outputValues
}