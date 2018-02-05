Function Get-SPCacheHostInfo
{
    [CmdletBinding()]
    param (
        [hashtable]$PoShMonConfiguration,
        $FirstSPCacheServer
    )

    $clusterResponse = $null
    
    try {
        $remoteSession = New-PSSession -ComputerName $FirstSPCacheServer.Server.DisplayName -ConfigurationName $PoShMonConfiguration.General.ConfigurationName

        $clusterResponse = Invoke-Command -Session $remoteSession -ScriptBlock {
                            Add-PSSnapin Microsoft.SharePoint.PowerShell

                            Use-CacheCluster

                            Get-CacheHost
                    }
    } finally {
        if ($remoteSession -ne $null) { Disconnect-RemoteSession $remoteSession }
    }

    return $clusterResponse
}