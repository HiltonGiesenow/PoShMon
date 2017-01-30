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
            #General = General
            #OperatingSystem = OperatingSystem
            WebSite = $null
            Notifications = @()
        }

    $configurationItems = . $bodyScript

    foreach ($configurationItem in $configurationItems)
    {
        if ($configurationItem.TypeName -eq "PoShMon.ConfigurationItems.General")
            { $newConfiguration.General = $configurationItem }
        if ($configurationItem.TypeName -eq "PoShMon.ConfigurationItems.OperatingSystem")
            { $newConfiguration.OperatingSystem = $configurationItem }
        if ($configurationItem.TypeName -eq "PoShMon.ConfigurationItems.WebSite")
            { $newConfiguration.WebSite = $configurationItem }
        elseif ($configurationItem.TypeName.StartsWith("PoShMon.ConfigurationItems.NotificationCollection"))
            { 
                $newConfiguration.Notifications += $configurationItem }
    }

    if ($newConfiguration.General -eq $null)
        { $newConfiguration.General = General }
    if ($newConfiguration.OperatingSystem -eq $null)
        { $newConfiguration.OperatingSystem = OperatingSystem }

    return $newConfiguration
>>>>>>> 4a8496a3e561ccb11cd44dba935326bec986b07e
}