Function New-NotificationsConfig
{
    [CmdletBinding()]
    param(
        [parameter(Mandatory)]
        [scriptblock]$bodyScript,

        [ValidateSet("All", "OnlyOnFailure", "None")]
        [string]$When = "All"
    )

    if ($Script:PoShMon.ConfigurationItems.Notifications -eq $null)
        { $Script:PoShMon.ConfigurationItems.Notifications = @{} }
    if ($Script:PoShMon.ConfigurationItems.Notifications.$When -eq $null)
        { $Script:PoShMon.ConfigurationItems.Notifications.$When = @{} }
    else {
        throw "'$When' Notification group already created"
    }

    $sinks = . $bodyScript

    return @{
            TypeName = "PoShMon.ConfigurationItems.NotificationCollection-$When"
            Sinks = $sinks
            When = $When
        }
}