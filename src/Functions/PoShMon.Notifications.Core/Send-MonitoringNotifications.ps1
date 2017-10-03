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

    foreach ($notificationSink in $NotificationSinks)
    {
        if ($notificationSink.TypeName -eq 'PoShMon.ConfigurationItems.Notifications.Email')
        {
                Send-PoShMonEmail `
                                -PoShMonConfiguration $PoShMonConfiguration `
                                -EmailNotificationSink $notificationSink `
                                -Subject (New-EmailSubject $PoShMonConfiguration $TestOutputValues) `
                                -Body (New-EmailBody $PoShMonConfiguration $SendNotificationsWhen $TestOutputValues $TotalElapsedTime) `
                                -Critical $atLeastOneFailure
        }
        elseif ($notificationSink.TypeName -eq 'PoShMon.ConfigurationItems.Notifications.Pushbullet')
        {
                Send-PushbulletMessage `
                                -PoShMonConfiguration $PoShMonConfiguration `
                                -PushbulletNotificationSink $notificationSink `
                                -Subject (New-PushbulletMessageSubject $PoShMonConfiguration $TestOutputValues) `
                                -Body (New-PushbulletMessageBody $PoShMonConfiguration $SendNotificationsWhen $TestOutputValues $TotalElapsedTime) `
                                -Critical $atLeastOneFailure
        }
        elseif ($notificationSink.TypeName -eq 'PoShMon.ConfigurationItems.Notifications.O365Teams')
        {
                Send-O365TeamsMessage `
                                -PoShMonConfiguration $PoShMonConfiguration `
                                -O365TeamsNotificationSink $notificationSink `
                                -Subject (New-O365TeamsMessageSubject $PoShMonConfiguration $TestOutputValues) `
                                -Body (New-O365TeamsMessageBody $PoShMonConfiguration $SendNotificationsWhen $TestOutputValues $TotalElapsedTime) `
                                -Critical $atLeastOneFailure
         }
         elseif ($notificationSink.TypeName -eq 'PoShMon.ConfigurationItems.Notifications.OperationValidationFramework')
         {
                Invoke-OperationValidationFrameworkScan `
                                -PoShMonConfiguration $PoShMonConfiguration `
                                -OperationValidationFrameworkNotificationSink $notificationSink `
                                -TestOutputValues $TestOutputValues `
                                -Critical $atLeastOneFailure
         } else {
            Write-Error "Notitication Sink '$($notificationSink.TypeName)' type not found"
        }
    }
}