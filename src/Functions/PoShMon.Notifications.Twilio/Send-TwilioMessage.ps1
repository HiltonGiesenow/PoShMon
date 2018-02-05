Function Send-TwilioMessage
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
							To   = $NotificationSink.ToAddress
							From = $NotificationSink.FromAddress
							Body = $Subject + "`r`n" + $Body
             			}

	$pair = "$($NotificationSink.SID):$($NotificationSink.Token)"
	$encodedCredentials = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
						 
    $params = @{
        Uri = "https://api.twilio.com/2010-04-01/Accounts/$($NotificationSink.SID)/Messages.json"
        Headers = @{ 'Authorization' = "Basic $encodedCredentials" }
        Method = "Post"
        Body = $finalMessageBody
		ErrorAction = "SilentlyContinue"
		UseBasicParsing = $true
    }

	$jsonBody = $finalMessageBody | ConvertTo-Json
	Write-Verbose "Calling $($params.Uri) with $jsonBody"

    if ($PoShMonConfiguration.General.InternetAccessRunAsAccount -ne $null)
        { $params.Add("Credential", $PoShMonConfiguration.General.InternetAccessRunAsAccount) }

    if ([string]::IsNullOrEmpty($PoShMonConfiguration.General.ProxyAddress) -eq $false)
        { $params.Add("Proxy", $PoShMonConfiguration.General.ProxyAddress) }

    Invoke-WebRequest @params
 }