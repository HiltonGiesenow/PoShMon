Function Send-PushbulletMessage
{
    [CmdletBinding()]
    Param(
		[hashtable]$PoShMonConfiguration,
		[hashtable]$NotificationSink,
		[string]$Subject,
		[string]$Body,
        [bool]$Critical
    )

    $finalMessageBody = @{
                device_iden = $NotificationSink.DeviceId
                type = "note"
                title = $Subject
                body = $Body
             }

    $params = @{
        Uri = "https://api.pushbullet.com/v2/pushes"
        Headers = @{ 'Access-Token' = $NotificationSink.AccessToken }
        Method = "Post"
        Body = $finalMessageBody
        ErrorAction = "SilentlyContinue"
    }

    if ($PoShMonConfiguration.General.InternetAccessRunAsAccount -ne $null)
        { $params.Add("Credential", $PoShMonConfiguration.General.InternetAccessRunAsAccount) }

    if ([string]::IsNullOrEmpty($PoShMonConfiguration.General.ProxyAddress) -eq $false)
        { $params.Add("Proxy", $PoShMonConfiguration.General.ProxyAddress) }

    $sendMessage = Invoke-WebRequest @params
 }