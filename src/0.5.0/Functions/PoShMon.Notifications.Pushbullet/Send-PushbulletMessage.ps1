Function Send-PushbulletMessage
{
    [CmdletBinding()]
    Param(
        [hashtable]$PoShMonConfiguration,
        [hashtable]$PushbulletNotificationSink,
        [ValidateSet("All","OnlyOnFailure","None")][string]$SendNotificationsWhen,
        [object[]]$TestOutputValues,
        [TimeSpan]$TotalElapsedTime
    )

    $messageTitle = Get-PushbulletMessageHeading $TestOutputValues

    $messageBody = ''
    foreach ($testOutputValue in $testOutputValues)
    {
        if ($testOutputValue.NoIssuesFound) { $foundValue = "No" } else { $foundValue = "Yes" }
        $messageBody += "$($testOutputValue.SectionHeader) : issue(s) found: $foundValue \r\n"
    }

    $body = @{
                device_iden = $PushbulletNotificationSink.DeviceId
                type = "note"
                title = $messageTitle
                body = $messageBody
             }

    $pushbulletSendUrl = "https://api.pushbullet.com/v2/pushes"
    $credential = New-Object System.Management.Automation.PSCredential ($PushbulletNotificationSink.AccessToken, (ConvertTo-SecureString $PushbulletNotificationSink.AccessToken -AsPlainText -Force))

    $sendMessage = Invoke-WebRequest -Uri $pushbulletSendUrl -Credential $credential -Method Post -Body $body -ErrorAction SilentlyContinue
 }