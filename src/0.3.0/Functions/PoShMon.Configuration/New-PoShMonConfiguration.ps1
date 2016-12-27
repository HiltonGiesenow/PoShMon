Function New-PoShMonConfiguration
{
    [CmdletBinding()]
    param(
        [parameter(Mandatory, Position = 0)]
        [scriptblock]$bodyScript
    )

    $Script:PoShMon = @{}
    $Script:PoShMon.ConfigurationItems = @{}

    $newConfiguration = @{
            TypeName = 'PoShMon.Configuration'
            General = $null
            Notifications = @()
        }

    $configurationItems = . $bodyScript

    foreach ($configurationItem in $configurationItems)
    {
        if ($configurationItem.TypeName -eq "PoShMon.ConfigurationItems.General")
            { $newConfiguration.General = $configurationItem }
        elseif ($configurationItem.TypeName.StartsWith("PoShMon.ConfigurationItems.NotificationCollection"))
            { $newConfiguration.Notifications += $configurationItem }
    }

    return $newConfiguration
}