Function Send-O365TeamsMessage
{
    [CmdletBinding()]
    Param(
        [hashtable]$PoShMonConfiguration,
        [hashtable]$O365TeamsNotificationSink,
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

    $headers = @{"accept"="application/json"; "Content-Type"="application/json"}
    $body = "{""text"": ""$messageBody""}"

    $response = Invoke-WebRequest -Uri $O365TeamsNotificationSink.TeamsWebHookUrl -Headers $headers -Body $body -Method Post
 }