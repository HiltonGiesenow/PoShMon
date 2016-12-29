Function Pushbullet
{
    [CmdletBinding()]
    param(
        [parameter(Mandatory)]
        [string[]]$AccessToken,
        [parameter(Mandatory)]
        [string]$DeviceId = $null
    )

    return @{
        TypeName = 'PoShMon.ConfigurationItems.Notifications.Pushbullet'
        ApiKey = $AccessToken
        DeviceId = $DeviceId
    }
}