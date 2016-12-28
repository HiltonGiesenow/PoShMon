Function Send-Notifications
{
    [CmdletBinding()]
    Param(
        [hashtable]$PoShMonConfiguration,
        [hashtable]$NotificationSinks,
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
        } else {
            Write-Error "Notitication Sink '$notificationSink.TypeName' type not found"
        }
    }
}