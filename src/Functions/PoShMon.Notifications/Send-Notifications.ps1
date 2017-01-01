Function Send-Notifications
{
    [CmdletBinding()]
    Param(
        [hashtable]$PoShMonConfiguration,
        [object[]]$NotificationSinks,
        [ValidateSet("All","OnlyOnFailure","None")][string]$SendNotificationsWhen,
        [object[]]$TestOutputValues,
        [TimeSpan]$TotalElapsedTime
    )

    foreach ($notificationSink in $NotificationSinks)
    {
        if ($notificationSink.TypeName -eq 'PoShMon.ConfigurationItems.Notifications.Email')
        {
                Send-PoShMonEmail `
                                -PoShMonConfiguration $PoShMonConfiguration `
                                -EmailNotificationSink $notificationSink `
                                -Subject (New-EmailSubject $PoShMonConfiguration $TestOutputValues) `
                                -Body (New-EmailBody $PoShMonConfiguration $SendNotificationsWhen $TestOutputValues $TotalElapsedTime)
        }
        elseif ($notificationSink.TypeName -eq 'PoShMon.ConfigurationItems.Notifications.Pushbullet')
        {
                Send-PushbulletMessage `
                                -PoShMonConfiguration $PoShMonConfiguration `
                                -PushbulletNotificationSink $notificationSink `
                                -Subject (New-PushbulletMessageSubject $PoShMonConfiguration $TestOutputValues) `
                                -Body (New-PushbulletMessageBody $PoShMonConfiguration $SendNotificationsWhen $TestOutputValues $TotalElapsedTime)
        }
        elseif ($notificationSink.TypeName -eq 'PoShMon.ConfigurationItems.Notifications.O365Teams')
        {
                Send-O365TeamsMessage `
                                -PoShMonConfiguration $PoShMonConfiguration `
                                -O365TeamsNotificationSink $notificationSink `
                                -Subject (New-O365TeamsMessageSubject $PoShMonConfiguration $TestOutputValues) `
                                -Body (New-O365TeamsMessageBody $PoShMonConfiguration $SendNotificationsWhen $TestOutputValues $TotalElapsedTime)
         } else {
            Write-Error "Notitication Sink '$notificationSink.TypeName' type not found"
        }
    }
}