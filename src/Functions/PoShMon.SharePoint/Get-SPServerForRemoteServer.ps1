Function Get-SPServerForRemoteServer
{
    [CmdletBinding()]
    param (
        [hashtable]$PoShMonConfiguration,
        [string]$ServerName
    )

    try {
        $remoteSession = New-PSSession -ComputerName $ServerName -ConfigurationName $PoShMonConfiguration.General.ConfigurationName

        $server = Invoke-Command -Session $remoteSession -ScriptBlock {
                                Add-PSSnapin Microsoft.SharePoint.PowerShell
                                Get-SPServer | Where Address -eq $env:COMPUTERNAME
                            }

        return $server
    } finally {
        Disconnect-RemoteSession $remoteSession
    }
}