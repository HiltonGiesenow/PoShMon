Function Test-SPDistributedCacheHealth
{
    [CmdletBinding()]
    param (
        #[System.Management.Automation.Runspaces.PSSession]$RemoteSession
        [hashtable]$PoShMonConfiguration
    )

    $mainOutput = Get-InitialOutputWithTimer -SectionHeader "Distributed Cache Status" -OutputHeaders ([ordered]@{ 'Server' = 'Server'; 'SharePointStatus' = 'SharePoint Status'; 'CacheClusterMemberStatus' = 'Cache Cluster Member Status' })

    $cacheServers = Invoke-RemoteCommand -PoShMonConfiguration $PoShMonConfiguration -ScriptBlock {
                                return Get-SPServiceInstance | ? {($_.service.tostring()) -eq "SPDistributedCacheService Name=AppFabricCachingService"} | select Server, Status
                            }

    $firstOnlineServer = $cacheServers | Where-Object { $_.Status.Value -eq "Online" } | Select -First 1

    if ($firstOnlineServer -ne $null) #i.e. no healthy servers found
    {
        try {
            $remoteSession = New-PSSession -ComputerName $firstOnlineServer.Server.DisplayName -ConfigurationName $PoShMonConfiguration.General.ConfigurationName
    
            $clusterResponse = Invoke-Command -Session $remoteSession -ScriptBlock {
                                Add-PSSnapin Microsoft.SharePoint.PowerShell

                                Use-CacheCluster

                                Get-CacheHost
                        }
        } finally {
            if ($remoteSession -ne $null) { Disconnect-RemoteSession $remoteSession }
        }
    } else {
        Write-Warning "`tNo healthy servers found in cache cluster from Get-SPServiceInstance"

        $mainOutput.NoIssuesFound = $false #TODO: this won't return a specified response
    }


                            # Possible extensions:
    <#
    Use-CacheCluster
        Get-CacheHost

        Get-CacheClusterHealth
    #>

    foreach ($cacheServer in $cacheServers)
    {
        $highlight = @()

        Write-Verbose "`t$($cacheServer.Server.DisplayName) : $($cacheServer.Status.Value)"

        if ($cacheServer.Status.Value -ne 'Online')
        {
            $mainOutput.NoIssuesFound = $false

            Write-Warning ("`t" + $cacheServer.Server.DisplayName + " is listed as " + $cacheServer.Status.Value)

            $highlight += 'Status'
        }

        $clusterServer = $clusterResponse | Where HostName -Like ($cacheServer.Server.DisplayName + "*")
        
        if ($clusterServer -ne $null)
        {
            Write-Verbose "`t`t$($clusterServer.HostName) : $($clusterServer.Status)"
            
            $clusterMemberUpDown = $clusterServer.Status

            if ($clusterServer.Status -ne "Up")
            {
                Write-Warning ("`t" + $clusterServer.HostName + " is listed as " + $clusterServer.Status)

                $highlight += 'CacheClusterMemberStatus'

                $mainOutput.NoIssuesFound = $false
            }
        } else {
            Write-Warning "`tCache cluster entry not found for $($cacheServer.Server.DisplayName)"
            
            $serverUpDown = "Down"
        }

        $mainOutput.OutputValues += [pscustomobject]@{
            'Server' = $cacheServer.Server.DisplayName;
            'SharePointStatus' = $cacheServer.Status.Value;
            'CacheClusterMemberStatus' = $clusterMemberUpDown;
            'Highlight' = $highlight
        }
    }

    return (Complete-TimedOutput $mainOutput)
}