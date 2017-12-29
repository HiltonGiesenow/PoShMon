Function New-ShortMessageBody
{
    [CmdletBinding()]
    Param(
        [hashtable]$PoShMonConfiguration,
        [ValidateSet("All","OnlyOnFailure","None")][string]$SendNotificationsWhen,
        [System.Collections.ArrayList]$TestOutputValues,
        [TimeSpan]$TotalElapsedTime
    )

    $messageBody = ''

    foreach ($testOutputValue in $testOutputValues)
    {
        if ($testOutputValue.NoIssuesFound) { $foundValue = "No" } else { $foundValue = "Yes" }
        if ($testOutputValue.ContainsKey("Exception"))
            { $foundValue += " (Exception occurred)" }
        $messageBody += "$($testOutputValue.SectionHeader) : issue(s) found - $foundValue `r`n"
    }

    return $messageBody
}