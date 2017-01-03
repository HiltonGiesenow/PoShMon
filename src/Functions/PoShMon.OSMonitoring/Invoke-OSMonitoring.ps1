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

    $outputValues = @()

    # Event Logs
    if (!$PoShMonConfiguration.General.TestsToSkip.Contains("EventLogs"))
        { $outputValues += Test-EventLogs $PoShMonConfiguration }

    # Drive Space
    if (!$PoShMonConfiguration.General.TestsToSkip.Contains("DriveSpace"))
            { $outputValues += Test-DriveSpace $PoShMonConfiguration }

    $stopWatch.Stop()

    Process-Notifications -PoShMonConfiguration $PoShMonConfiguration -TestOutputValues $outputValues -TotalElapsedTime $stopWatch.Elapsed

    return $outputValues
}