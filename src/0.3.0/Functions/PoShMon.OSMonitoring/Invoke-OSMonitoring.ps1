Function Invoke-OSMonitoring
{
    [CmdletBinding()]
    Param(
        #[parameter(Mandatory=$true, HelpMessage="something")]
        [string]$EnvironmentName = "Environment",
        [int]$MinutesToScanHistory = 15,
        [string[]]$ServerNames = @(),
        [string[]]$MailToList = @(),
        [string[]]$EventLogCodes = 'Critical',
        [hashtable]$EventIDIgnoreList = @{},
        [string[]]$TestsToSkip = @(),
        [ValidateSet("All","OnlyOnFailure","None")][string]$SendMailWhen = "All",
        [string]$MailFrom,
        [string]$SMTPAddress
    )

    $stopWatch = [System.Diagnostics.Stopwatch]::StartNew()

    $outputValues = @()

    # Event Logs
    if (!$TestsToSkip.Contains("EventLogs"))
    {
        foreach ($eventLogCode in $EventLogCodes)
            { $outputValues += Test-EventLogs -ServerNames $ServerNames -MinutesToScanHistory $MinutesToScanHistory -SeverityCode $eventLogCode }
    }

    # Drive Space
    if (!$TestsToSkip.Contains("DriveSpace"))
        { $outputValues += Test-DriveSpace -ServerNames $ServerNames }

    $stopWatch.Stop()

    Confirm-SendMonitoringEmail -TestOutputValues $outputValues -SkippedTests $TestsToSkip -SendMailWhen $SendMailWhen `
        -EnvironmentName $EnvironmentName -MailToList $MailToList -MailFrom $MailFrom -SMTPAddress $SMTPAddress -TotalElapsedTime $stopWatch.Elapsed

    return $outputValues
}