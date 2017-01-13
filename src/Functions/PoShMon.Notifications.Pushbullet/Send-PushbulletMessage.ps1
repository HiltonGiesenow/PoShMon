Function Send-PushbulletMessage
{
    [CmdletBinding()]
    Param(
        [hashtable]$PoShMonConfiguration,
        [hashtable]$PushbulletNotificationSink,
        [string]$Subject,
        [string]$Body,
        [bool]$Critical
    )

    $finalMessageBody = @{
                device_iden = $PushbulletNotificationSink.DeviceId
                type = "note"
                title = $subject
                body = $body
             }

    $pushbulletSendUrl = "https://api.pushbullet.com/v2/pushes"

    $headers = @{ 'Access-Token' = $PushbulletNotificationSink.AccessToken }

    $sendMessage = Invoke-WebRequest -Uri $pushbulletSendUrl -Headers $headers -Method Post -Body $finalMessageBody -ErrorAction SilentlyContinue
 }