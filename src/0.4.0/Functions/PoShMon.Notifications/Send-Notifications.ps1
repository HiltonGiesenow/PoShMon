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
                                -SendNotificationsWhen $SendNotificationsWhen `
                                -TestOutputValues $TestOutputValues `
                                -TotalElapsedTime $TotalElapsedTime
        }
        elseif ($notificationSink.TypeName -eq 'PoShMon.ConfigurationItems.Notifications.Pushbullet')
        {
                Send-PushbulletMessage `
                                -PoShMonConfiguration $PoShMonConfiguration `
                                -PushbulletNotificationSink $notificationSink `
                                -SendNotificationsWhen $SendNotificationsWhen `
                                -TestOutputValues $TestOutputValues `
                                -TotalElapsedTime $TotalElapsedTime
        } else {
            Write-Error "Notitication Sink '$notificationSink.TypeName' type not found"
        }
    }
}