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

    #$pushbulletSendUrl = "https://api.pushbullet.com/v2/pushes"

    #$headers = @{ 'Access-Token' = $PushbulletNotificationSink.AccessToken }

    $params = @{
        Uri = "https://api.pushbullet.com/v2/pushes"
        Headers = @{ 'Access-Token' = $PushbulletNotificationSink.AccessToken }
        Method = "Post"
        Body = $finalMessageBody
        ErrorAction = "SilentlyContinue"
    }

    if ($PoShMonConfiguration.General.InternetAccessRunAsAccount -ne $null)
        { $params.Add("Credential", $PoShMonConfiguration.General.InternetAccessRunAsAccount) }

    if ($PoShMonConfiguration.General.ProxyAddress -ne $null)
        { $params.Add("Proxy", $PoShMonConfiguration.General.ProxyAddress) }

    $sendMessage = Invoke-WebRequest @params
 }