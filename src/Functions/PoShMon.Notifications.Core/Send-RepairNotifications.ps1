Function Send-RepairNotifications
{
    [CmdletBinding()]
    Param(
        [hashtable]$PoShMonConfiguration,
        [object[]]$NotificationSinks,
        [object[]]$RepairOutputValues
    )

    foreach ($notificationSink in $NotificationSinks)
    {
        if ($notificationSink.TypeName -eq 'PoShMon.ConfigurationItems.Notifications.Email')
        {
                Send-PoShMonEmail `
                                -PoShMonConfiguration $PoShMonConfiguration `
                                -EmailNotificationSink $notificationSink `
                                -Subject (New-EmailRepairSubject $PoShMonConfiguration $RepairOutputValues) `
                                -Body (New-EmailRepairBody $PoShMonConfiguration $RepairOutputValues) `
                                -Critical $false
        }
        elseif ($notificationSink.TypeName -eq 'PoShMon.ConfigurationItems.Notifications.Pushbullet')
        {
                Send-PushbulletMessage `
                                -PoShMonConfiguration $PoShMonConfiguration `
                                -PushbulletNotificationSink $notificationSink `
                                -Subject (New-PushbulletRepairMessageSubject $PoShMonConfiguration $RepairOutputValues) `
                                -Body (New-PushbulletRepairMessageBody $PoShMonConfiguration $RepairOutputValues) `
                                -Critical $false
        }
        elseif ($notificationSink.TypeName -eq 'PoShMon.ConfigurationItems.Notifications.O365Teams')
        {
                Send-O365TeamsMessage `
                                -PoShMonConfiguration $PoShMonConfiguration `
                                -O365TeamsNotificationSink $notificationSink `
                                -Subject (New-O365TeamsRepairMessageSubject $PoShMonConfiguration $RepairOutputValues) `
                                -Body (New-O365TeamsRepairMessageBody $PoShMonConfiguration $RepairOutputValues) `
                                -Critical $false
         } else {
            Write-Error "Notitication Sink '$notificationSink.TypeName' type not found"
        }
    }
}