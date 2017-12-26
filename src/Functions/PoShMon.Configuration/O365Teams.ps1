Function New-O365TeamsConfig
{
    [CmdletBinding()]
    param(
        [parameter(Mandatory)]
        [string]$TeamsWebHookUrl
    )

    return @{
        TypeName = 'PoShMon.ConfigurationItems.Notifications.O365Teams'
        TeamsWebHookUrl = $TeamsWebHookUrl
    }
}