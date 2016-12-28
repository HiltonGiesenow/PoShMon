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

    $body = @{
                device_iden = $PushbulletNotificationSink.DeviceId
                type = "note"
                title = "My Title"
                body = "My long message 12345678901234567890123456789012345678901234567890123456789012345678901234567890"
             }

    $pushbulletSendUrl = "https://api.pushbullet.com/v2/pushes"
    $credential = New-Object System.Management.Automation.PSCredential ($PushbulletNotificationSink.ApiKey, (ConvertTo-SecureString $PushbulletNotificationSink.ApiKey -AsPlainText -Force))

    $sendMessage = Invoke-WebRequest -Uri $pushbulletSendUrl -Credential $credential -Method Post -Body $body -ErrorAction SilentlyContinue
 }