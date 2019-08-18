Function New-EmailConfig
{
    [CmdletBinding()]
    param(
        [parameter(Mandatory)]
        [string[]]$ToAddress,
        [parameter(Mandatory)]
        [string]$FromAddress,
        [parameter(Mandatory)]
        [string]$SmtpServer,
        [int]$Port = 25,
        [pscredential]$SmtpCredential,
        [bool]$UseSSL = $false
    )

    return @{
        TypeName = 'PoShMon.ConfigurationItems.Notifications.Email'
        ToAddress = $ToAddress
        FromAddress = $FromAddress
        SmtpServer = $SmtpServer
        Port = $Port
        SmtpCredential = $SmtpCredential
        UseSSL = $UseSSL
    }
}