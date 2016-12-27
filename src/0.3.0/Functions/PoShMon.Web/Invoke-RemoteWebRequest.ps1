Function Invoke-RemoteWebRequest
{
    [CmdletBinding()]
    param (
        [string]$SiteUrl,
        [string]$ServerName,
        [string]$ConfigurationName
    )

    Write-Verbose "Connecting to $ServerName..."

    try {
        $remoteSession = Connect-RemoteSession -ServerName $ServerName -ConfigurationName $ConfigurationName

        $webResponse = Invoke-Command -Session $remoteSession -ScriptBlock {
                                    param($SiteUrl)
                                    Invoke-WebRequest $SiteUrl -UseDefaultCredentials
                                } -ArgumentList $SiteUrl
    } finally {
        Disconnect-RemoteSession $remoteSession
    }

    return $webResponse
}