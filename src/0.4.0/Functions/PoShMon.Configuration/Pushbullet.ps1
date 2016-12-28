Function Pushbullet
{
    [CmdletBinding()]
    param(
        [parameter(Mandatory)]
        [string[]]$ApiKey,
        [parameter(Mandatory)]
        [string]$DeviceId = $null
    )

    return @{
        TypeName = 'PoShMon.ConfigurationItems.Notifications.Pushbullet'
        ApiKey = $ApiKey
        DeviceId = $DeviceId
    }
}