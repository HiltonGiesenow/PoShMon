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

    if ($PoShMonConfiguration["Notifications"].Count -gt 0)
    {
        foreach ($configurationItem in $PoShMonConfiguration["Notifications"])
        {
            if ($configurationItem.TypeName.StartsWith("PoShMon.ConfigurationItems.NotificationCollection"))
            {
                foreach ($notificationSink in $configurationItem.Sinks)
                {
                    if ($notificationSink.TypeName -eq 'PoShMon.ConfigurationItems.Notifications.Email')
                    {
                            Send-PoShMonEmail `
                                            -PoShMonConfiguration $PoShMonConfiguration `
                                            -EmailNotificationSink $notificationSink `
                                            -Subject (New-EmailExceptionSubject $PoShMonConfiguration $Action) `
                                            -Body (New-EmailExceptionBody $Exception $bodyAction) `
                                            -Critical $true
                    }
                    elseif ($notificationSink.TypeName -eq 'PoShMon.ConfigurationItems.Notifications.Pushbullet')
                    {
                            Send-PushbulletMessage `
                                            -PoShMonConfiguration $PoShMonConfiguration `
                                            -PushbulletNotificationSink $notificationSink `
                                            -Subject (New-PushbulletExceptionSubject $PoShMonConfiguration $Action) `
                                            -Body (New-PushbulletExceptionBody $Exception $bodyAction) `
                                            -Critical $true
                    }
                    elseif ($notificationSink.TypeName -eq 'PoShMon.ConfigurationItems.Notifications.O365Teams')
                    {
                            Send-O365TeamsMessage `
                                            -PoShMonConfiguration $PoShMonConfiguration `
                                            -O365TeamsNotificationSink $notificationSink `
                                            -Subject (New-O365TeamsExceptionSubject $PoShMonConfiguration $Action) `
                                            -Body (New-O365TeamsExceptionBody $Exception $bodyAction) `
                                            -Critical $true
                    } else {
                        Write-Error "Notitication Sink '$notificationSink.TypeName' type not found"
                    }
                }
            }
        }
    }
}