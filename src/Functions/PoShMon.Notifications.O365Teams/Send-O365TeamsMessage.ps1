Function Send-O365TeamsMessage
{
    [CmdletBinding()]
    Param(
        [hashtable]$PoShMonConfiguration,
        [hashtable]$O365TeamsNotificationSink,
        [string]$Subject,
        [string]$Body,
        [bool]$Critical
    )

    $combinedMessageBody = $subject + $body
    
    #$headers = @{"accept"="application/json"; "Content-Type"="application/json"}
    $finalMessageBody = "{""text"": ""$combinedMessageBody""}"

    $params = @{
        Uri = $O365TeamsNotificationSink.TeamsWebHookUrl
        Headers = @{"accept"="application/json"; "Content-Type"="application/json"}
        Method = "Post"
        Body = $finalMessageBody
        ErrorAction = "SilentlyContinue"
    }

    if ($PoShMonConfiguration.General.InternetAccessRunAsAccount -ne $null)
        { $params.Add("Credential", $PoShMonConfiguration.General.InternetAccessRunAsAccount) }

    if ([string]::IsNullOrEmpty($PoShMonConfiguration.General.ProxyAddress) -eq $false)
        { $params.Add("Proxy", $PoShMonConfiguration.General.ProxyAddress) }

    #$response = Invoke-WebRequest -Uri $O365TeamsNotificationSink.TeamsWebHookUrl -Headers $headers -Body $finalMessageBody -Method Post
    $response = Invoke-WebRequest @params
 }