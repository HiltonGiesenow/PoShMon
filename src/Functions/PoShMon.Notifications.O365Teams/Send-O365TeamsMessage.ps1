Function Send-O365TeamsMessage
{
    [CmdletBinding()]
    Param(
        [hashtable]$PoShMonConfiguration,
        [hashtable]$O365TeamsNotificationSink,
        [string]$Subject,
        [string]$Body
    )

    $combinedMessageBody = $subject + $body
    
    $headers = @{"accept"="application/json"; "Content-Type"="application/json"}
    $finalMessageBody = "{""text"": ""$combinedMessageBody""}"

    $response = Invoke-WebRequest -Uri $O365TeamsNotificationSink.TeamsWebHookUrl -Headers $headers -Body $finalMessageBody -Method Post
 }