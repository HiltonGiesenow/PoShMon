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
        if ($configurationItem.TypeName -eq "PoShMon.ConfigurationItems.SharePoint")
            { $newConfiguration.SharePoint = $configurationItem }
        if ($configurationItem.TypeName -eq "PoShMon.ConfigurationItems.Extensibility")
            { $newConfiguration.Extensibility = $configurationItem }
        elseif ($configurationItem.TypeName.StartsWith("PoShMon.ConfigurationItems.NotificationCollection"))
            { 
                $newConfiguration.Notifications += $configurationItem }
    }

    if ($newConfiguration.General -eq $null)
        { $newConfiguration.General = General -ServerNames $Env:COMPUTERNAME }
    if ($newConfiguration.OperatingSystem -eq $null)
        { $newConfiguration.OperatingSystem = OperatingSystem }

    return $newConfiguration
}