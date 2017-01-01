Function Send-ExceptionNotifications
{
    [CmdletBinding()]
    Param(
        [hashtable]$PoShMonConfiguration,
        [System.Exception]$Exception
    )

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
                                            -Subject (New-EmailExceptionSubject $PoShMonConfiguration) `
                                            -Body (New-EmailExceptionBody $Exception)
                    }
                    elseif ($notificationSink.TypeName -eq 'PoShMon.ConfigurationItems.Notifications.Pushbullet')
                    {
                            Send-PushbulletMessage `
                                            -PoShMonConfiguration $PoShMonConfiguration `
                                            -PushbulletNotificationSink $notificationSink `
                                            -Subject (New-PushbulletExceptionSubject $PoShMonConfiguration) `
                                            -Body (New-PushbulletExceptionBody $Exception)
                    }
                    elseif ($notificationSink.TypeName -eq 'PoShMon.ConfigurationItems.Notifications.O365Teams')
                    {
                            Send-O365TeamsMessage `
                                            -PoShMonConfiguration $PoShMonConfiguration `
                                            -O365TeamsNotificationSink $notificationSink `
                                            -Subject (New-O365TeamsExceptionSubject $PoShMonConfiguration) `
                                            -Body (New-O365TeamsExceptionBody $Exception)
                    } else {
                        Write-Error "Notitication Sink '$notificationSink.TypeName' type not found"
                    }
                }
            }
        }
    }
}