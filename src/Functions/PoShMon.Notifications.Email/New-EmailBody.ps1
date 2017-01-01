Function New-EmailBody
{
    [CmdletBinding()]
    Param(
        [hashtable]$PoShMonConfiguration,
        [ValidateSet("All","OnlyOnFailure","None")][string]$SendNotificationsWhen,
        [object[]]$TestOutputValues,
        [TimeSpan]$TotalElapsedTime
    )

    $emailBody = ''
            
    $emailBody += New-EmailHeader "$($PoShMonConfiguration.General.EnvironmentName) Monitoring Report"

    foreach ($testOutputValue in $testOutputValues)
    {
        if ($SendNotificationsWhen -eq "All" -or $testOutputValue.NoIssuesFound -eq $false)
            { $emailBody += New-TestOutputEmailBody -Output $testOutputValue }
    }

    $emailBody += New-EmailFooter $PoShMonConfiguration.General.TestsToSkip $TotalElapsedTime

    return $emailBody
}