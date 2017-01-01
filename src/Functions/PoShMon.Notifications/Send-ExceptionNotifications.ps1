Function Send-ExceptionNotifications
{
    [CmdletBinding()]
    Param(
        [hashtable]$PoShMonConfiguration,
        [string]$ExceptionMessage
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
                            Send-PoShMonExceptionEmail `
                                            -PoShMonConfiguration $PoShMonConfiguration `
                                            -EmailNotificationSink $notificationSink `
                                            -Subject (New-EmailExceptionSubject $PoShMonConfiguration) `
                                            -Body (New-EmailExceptionBody $ExceptionMessage)
                    }
                    elseif ($notificationSink.TypeName -eq 'PoShMon.ConfigurationItems.Notifications.Pushbullet')
                    {
                            Send-PushbulletExceptionMessage `
                                            -PoShMonConfiguration $PoShMonConfiguration `
                                            -PushbulletNotificationSink $notificationSink `
                                            -Subject (New-PushbulletExceptionSubject $PoShMonConfiguration) `
                                            -Body (New-PushbulletExceptionBody $ExceptionMessage)
                    }
                    elseif ($notificationSink.TypeName -eq 'PoShMon.ConfigurationItems.Notifications.O365Teams')
                    {
                            Send-O365TeamsExceptionMessage `
                                            -PoShMonConfiguration $PoShMonConfiguration `
                                            -PushbulletNotificationSink $notificationSink `
                                            -Subject (New-O365TeamsExceptionSubject $PoShMonConfiguration) `
                                            -Body (New-O365TeamsExceptionBody $ExceptionMessage)
                    } else {
                        Write-Error "Notitication Sink '$notificationSink.TypeName' type not found"
                    }
                }
            }
        }
    }
}