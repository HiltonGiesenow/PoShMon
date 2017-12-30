Function Send-RepairNotifications
{
    [CmdletBinding()]
    Param(
        [hashtable]$PoShMonConfiguration,
        [object[]]$NotificationSinks,
        [object[]]$RepairOutputValues
    )

	$params = @{
		PoShMonConfiguration = $PoShMonConfiguration
		RepairOutputValues = $RepairOutputValues
		NotificationSink = $null
	}

    foreach ($notificationSink in $NotificationSinks)
    {
		$params.NotificationSink = $notificationSink

        if ($notificationSink.TypeName -eq 'PoShMon.ConfigurationItems.Notifications.Email')
        {
            Send-EmailRepairMessage @params
        }
        elseif ($notificationSink.TypeName -eq 'PoShMon.ConfigurationItems.Notifications.Pushbullet')
        {
            Send-PushbulletRepairMessage @params
        }
        elseif ($notificationSink.TypeName -eq 'PoShMon.ConfigurationItems.Notifications.O365Teams')
        {
            Send-O365TeamsRepairMessage @params
		}
		elseif ($notificationSink.TypeName -eq 'PoShMon.ConfigurationItems.Notifications.Twilio')
		{
			Send-TwilioRepairMessage @params
		}
		else
		{
            Write-Error "Notitication Sink '$notificationSink.TypeName' type not found"
        }
    }
}