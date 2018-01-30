Function New-PushbulletConfig
{
    [CmdletBinding()]
    param(
        [parameter(Mandatory)]
        [string]$AccessToken,
        [parameter(Mandatory)]
        [string]$DeviceId = $null
    )

    return @{
        TypeName = 'PoShMon.ConfigurationItems.Notifications.Pushbullet'
        AccessToken = $AccessToken
        DeviceId = $DeviceId
    }
}