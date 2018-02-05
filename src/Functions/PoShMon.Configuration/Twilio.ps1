Function New-TwilioConfig
{
    [CmdletBinding()]
    param(
        [parameter(Mandatory)]
        [string]$SID,
        [parameter(Mandatory)]
        [string]$Token,
        [parameter(Mandatory)]
		[string]$FromAddress,
        [parameter(Mandatory)]
        [string]$ToAddress
    )

    return @{
        TypeName = 'PoShMon.ConfigurationItems.Notifications.Twilio'
        SID = $SID
        Token = $Token
        FromAddress = $FromAddress
        ToAddress = $ToAddress
    }
}