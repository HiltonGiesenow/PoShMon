Function Send-O365TeamsMessage
{
    [CmdletBinding()]
    Param(
		[hashtable]$PoShMonConfiguration,
		[hashtable]$NotificationSink,
		[string]$Subject,
		[string]$Body,
        [bool]$Critical
    )

	$combinedMessageBody = $Subject + $Body
	
    $finalMessageBody = "{""text"": ""$combinedMessageBody""}"

    $params = @{
        Uri = $NotificationSink.TeamsWebHookUrl
        Headers = @{"accept"="application/json"; "Content-Type"="application/json"}
        Method = "Post"
        Body = $finalMessageBody
        ErrorAction = "SilentlyContinue"
    }

    if ($PoShMonConfiguration.General.InternetAccessRunAsAccount -ne $null)
        { $params.Add("Credential", $PoShMonConfiguration.General.InternetAccessRunAsAccount) }

    if ([string]::IsNullOrEmpty($PoShMonConfiguration.General.ProxyAddress) -eq $false)
        { $params.Add("Proxy", $PoShMonConfiguration.General.ProxyAddress) }

    $response = Invoke-WebRequest @params
 }