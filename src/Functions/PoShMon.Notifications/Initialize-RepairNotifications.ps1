Function Initialize-RepairNotifications
{
    [CmdletBinding()]
    Param(
        [hashtable]$PoShMonConfiguration,
        [object[]]$RepairOutputValues
    )

    if ($RepairOutputValues.Count -gt 0)
    {
        if ($PoShMonConfiguration["Notifications"].Count -gt 0)
        {
            foreach ($configurationItem in $PoShMonConfiguration["Notifications"])
            {
                if ($configurationItem.TypeName.StartsWith("PoShMon.ConfigurationItems.NotificationCollection"))
                {
                    $sendNotificationsWhen = $configurationItem.TypeName.Substring("PoShMon.ConfigurationItems.NotificationCollection-".Length)

                    if ($sendNotificationsWhen -eq "None")
                    {
                        Write-Verbose "Notifications set to not send"
                    } else {
                        Send-RepairNotifications -PoShMonConfiguration $PoShMonConfiguration -NotificationSinks $configurationItem.Sinks -RepairOutputValues $RepairOutputValues
                    }
                }
            }
        }
    }
}