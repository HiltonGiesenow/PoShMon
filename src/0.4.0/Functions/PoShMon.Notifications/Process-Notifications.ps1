Function Process-Notifications
{
    [CmdletBinding()]
    Param(
        [hashtable]$PoShMonConfiguration,
        [object[]]$TestOutputValues,
        [TimeSpan]$TotalElapsedTime
    )

    $noIssuesFound = Confirm-NoIssuesFound $TestOutputValues

    if ($PoShMonConfiguration["Notifications"].Count -gt 0)
    {
        foreach ($configurationItem in $PoShMonConfiguration["Notifications"])
        {
            if ($configurationItem.TypeName.StartsWith("PoShMon.ConfigurationItems.NotificationCollection"))
            {
                $sendNotificationsWhen = $configurationItem.TypeName.Substring("PoShMon.ConfigurationItems.NotificationCollection-".Length)

                if ($sendNotificationsWhen -eq "None")
                {
                    Write-Verbose "Notifications set to not send. Issues found: $noIssuesFound"
                }
                elseif ($NoIssuesFound -and $sendNotificationsWhen -eq "OnlyOnFailure")
                {
                    Write-Verbose "No major issues encountered, skipping '$sendNotificationsWhen' notifications"
                }
                else
                {
                    Send-Notifications -PoShMonConfiguration $PoShMonConfiguration -NotificationSinks $configurationItem.Sinks -SendNotificationsWhen $sendNotificationsWhen -TestOutputValues $TestOutputValues -TotalElapsedTime $TotalElapsedTime
                }
            }
        }
    }
}