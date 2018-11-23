Function New-HtmlBody
{
    [CmdletBinding()]
    Param(
        [hashtable]$PoShMonConfiguration,
        [ValidateSet("All","OnlyOnFailure","None")][string]$SendNotificationsWhen,
        [System.Collections.ArrayList]$TestOutputValues,
        [TimeSpan]$TotalElapsedTime
    )

    $emailBody = ''
            
    $emailBody += New-HtmlHeader $PoShMonConfiguration "PoShMon Monitoring Report"

    foreach ($testOutputValue in $testOutputValues)
    {
        if ($SendNotificationsWhen -eq "All" -or $testOutputValue.NoIssuesFound -eq $false)
            { $emailBody += New-TestOutputHtmlBody -Output $testOutputValue }
    }

    $emailBody += New-HtmlFooter $PoShMonConfiguration $TotalElapsedTime

    return $emailBody
}