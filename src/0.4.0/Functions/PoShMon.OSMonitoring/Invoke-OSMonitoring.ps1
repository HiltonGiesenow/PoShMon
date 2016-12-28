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
    {
        foreach ($eventLogCode in $PoShMonConfiguration.OperatingSystem.EventLogCodes)
            { $outputValues += Test-EventLogs -ServerNames $PoShMonConfiguration.General.ServerNames -MinutesToScanHistory $PoShMonConfiguration.General.MinutesToScanHistory -SeverityCode $eventLogCode }
    }

    # Drive Space
    if (!$PoShMonConfiguration.General.TestsToSkip.Contains("DriveSpace"))
        { $outputValues += Test-DriveSpace -ServerNames $PoShMonConfiguration.General.ServerNames }

    $stopWatch.Stop()

    Process-Notifications -PoShMonConfiguration $PoShMonConfiguration -TestOutputValues $outputValues -TotalElapsedTime $stopWatch.Elapsed
    #Confirm-SendMonitoringEmail -TestOutputValues $outputValues -SkippedTests $PoShMonConfiguration.General.TestsToSkip -SendMailWhen "All" `
    #    -EnvironmentName $PoShMonConfiguration.General.EnvironmentName -MailToList $MailToList -MailFrom $MailFrom -SMTPAddress $SMTPAddress -TotalElapsedTime $stopWatch.Elapsed

    return $outputValues
}