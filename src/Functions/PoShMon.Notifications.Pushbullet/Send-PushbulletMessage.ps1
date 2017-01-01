Function Send-PushbulletMessage
{
    [CmdletBinding()]
    Param(
        [hashtable]$PoShMonConfiguration,
        [hashtable]$PushbulletNotificationSink,
        [string]$Subject,
        [string]$Body
    )

    $finalMessageBody = @{
                device_iden = $PushbulletNotificationSink.DeviceId
                type = "note"
                title = $subject
                body = $body
             }

    $pushbulletSendUrl = "https://api.pushbullet.com/v2/pushes"
    $credential = New-Object System.Management.Automation.PSCredential ($PushbulletNotificationSink.AccessToken, (ConvertTo-SecureString $PushbulletNotificationSink.AccessToken -AsPlainText -Force))

    $sendMessage = Invoke-WebRequest -Uri $pushbulletSendUrl -Credential $credential -Method Post -Body $finalMessageBody -ErrorAction SilentlyContinue
 }