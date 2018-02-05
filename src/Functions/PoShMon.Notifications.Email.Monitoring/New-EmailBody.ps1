Function New-EmailBody
{
    [CmdletBinding()]
    Param(
        [hashtable]$PoShMonConfiguration,
        [ValidateSet("All","OnlyOnFailure","None")][string]$SendNotificationsWhen,
        [System.Collections.ArrayList]$TestOutputValues,
        [TimeSpan]$TotalElapsedTime
    )

    $emailBody = ''
            
    $emailBody += New-EmailHeader $PoShMonConfiguration

    foreach ($testOutputValue in $testOutputValues)
    {
        if ($SendNotificationsWhen -eq "All" -or $testOutputValue.NoIssuesFound -eq $false)
            { $emailBody += New-TestOutputEmailBody -Output $testOutputValue }
    }

    $emailBody += New-EmailFooter $PoShMonConfiguration $TotalElapsedTime

    return $emailBody
}