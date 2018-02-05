Function Send-ExceptionNotifications
{
    [CmdletBinding()]
    Param(
        [hashtable]$PoShMonConfiguration,
        [System.Exception]$Exception,
        [ValidateSet("Monitoring", "Repairing")]
        [string]$Action = "Monitoring"
    )

    $bodyAction = if ($Action -eq "Monitoring") { "monitor" } else { "repair" }

	$params = @{
		PoShMonConfiguration = $PoShMonConfiguration
		NotificationSink = $null
		Exception = $Exception
		SubjectAction = $Action
		BodyAction = $bodyAction
	}

    if ($PoShMonConfiguration["Notifications"].Count -gt 0)
    {
        foreach ($configurationItem in $PoShMonConfiguration["Notifications"])
        {
            if ($configurationItem.TypeName.StartsWith("PoShMon.ConfigurationItems.NotificationCollection"))
            {
                foreach ($notificationSink in $configurationItem.Sinks)
                {
					$params.NotificationSink = $notificationSink

					if ($notificationSink.TypeName -eq 'PoShMon.ConfigurationItems.Notifications.Email')
                    {
						Send-EmailExceptionMessage @params
                    }
                    elseif ($notificationSink.TypeName -eq 'PoShMon.ConfigurationItems.Notifications.Pushbullet')
                    {
						Send-PushbulletExceptionMessage @params
                    }
                    elseif ($notificationSink.TypeName -eq 'PoShMon.ConfigurationItems.Notifications.O365Teams')
                    {
						Send-O365TeamsExceptionMessage @params
					}
                    elseif ($notificationSink.TypeName -eq 'PoShMon.ConfigurationItems.Notifications.Twilio')
                    {
						Send-TwilioExceptionMessage @params
					}
					else
					{
                        Write-Error "Notitication Sink '$notificationSink.TypeName' type not found"
                    }
                }
            }
        }
    } else {
        throw $Exception
    }
}