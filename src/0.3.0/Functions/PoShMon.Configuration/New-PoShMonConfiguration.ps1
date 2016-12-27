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
            Notifications = @()
        }

    $configurationItems = . $bodyScript

    foreach ($configurationItem in $configurationItems)
    {
        if ($configurationItem.TypeName.StartsWith("PoShMon.ConfigurationItems.NotificationCollection"))
            { $newConfiguration.Notifications += $configurationItem }
    }

    return $newConfiguration
}

<#
Sample:

$options = New-PoShMonConfiguration {
                Notifications -When All {
                    Email -ToAddress "hilton@giesenow.com" -FromAddress "bob@jones.com" -SmtpServer "smtp.company.com"
                }
                Notifications -When OnlyOnFailure {
                    Email `
                        -ToAddress "hilton@giesenow.com" `
                        -FromAddress "bob@jones.com" `
                        -SmtpServer "smtp.company.com" `
                        -Port 27
                }
            }

#>