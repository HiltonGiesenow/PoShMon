Function New-PushbulletMessageBody
{
    [CmdletBinding()]
    Param(
        [hashtable]$PoShMonConfiguration,
        [ValidateSet("All","OnlyOnFailure","None")][string]$SendNotificationsWhen,
        [object[]]$TestOutputValues,
        [TimeSpan]$TotalElapsedTime
    )

    $messageBody = ''
    foreach ($testOutputValue in $testOutputValues)
    {
        if ($testOutputValue.NoIssuesFound) { $foundValue = "No" } else { $foundValue = "Yes" }
        $messageBody += "$($testOutputValue.SectionHeader) : issue(s) found - $foundValue `r`n"
    }

    return $messageBody
}