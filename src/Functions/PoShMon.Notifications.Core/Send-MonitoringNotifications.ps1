Function Send-MonitoringNotifications
{
    [CmdletBinding()]
    Param(
        [hashtable]$PoShMonConfiguration,
        [object[]]$NotificationSinks,
        [ValidateSet("All","OnlyOnFailure","None")][string]$SendNotificationsWhen,
        [System.Collections.ArrayList]$TestOutputValues,
        [TimeSpan]$TotalElapsedTime
    )

    $atLeastOneFailure = $false
    foreach ($testOutputValue in $testOutputValues)
    {
        if ($SendNotificationsWhen -eq "OnlyOnFailure" -and $testOutputValue.NoIssuesFound -eq $false)
        {
            $atLeastOneFailure = $true
            break
        }
    }    

	$params = @{
		PoShMonConfiguration = $PoShMonConfiguration
		TestOutputValues = $TestOutputValues
		TotalElapsedTime = $TotalElapsedTime
		SendNotificationsWhen = $SendNotificationsWhen
		Critical = $atLeastOneFailure
		NotificationSink = $null
	}

    foreach ($notificationSink in $NotificationSinks)
    {
		$params.NotificationSink = $notificationSink
		
        if ($notificationSink.TypeName -eq 'PoShMon.ConfigurationItems.Notifications.Email')
        {
			Send-EmailMonitoringMessage @params
        }
        elseif ($notificationSink.TypeName -eq 'PoShMon.ConfigurationItems.Notifications.Pushbullet')
        {
			Send-PushbulletMonitoringMessage @params
        }
        elseif ($notificationSink.TypeName -eq 'PoShMon.ConfigurationItems.Notifications.O365Teams')
        {
			Send-O365TeamsMonitoringMessage @params
		}
		elseif ($notificationSink.TypeName -eq 'PoShMon.ConfigurationItems.Notifications.Twilio')
		{
			Send-TwilioMonitoringMessage @params
		}
        elseif ($notificationSink.TypeName -eq 'PoShMon.ConfigurationItems.Notifications.OperationValidationFramework')
        {
			Invoke-OperationValidationFrameworkScan @params
		}
		else
		{
            Write-Error "Notitication Sink '$($notificationSink.TypeName)' type not found"
        }
    }
}