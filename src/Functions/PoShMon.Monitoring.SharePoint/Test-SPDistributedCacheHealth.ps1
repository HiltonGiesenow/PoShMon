Function Test-SPDistributedCacheHealth
{
    [CmdletBinding()]
    param (
        #[System.Management.Automation.Runspaces.PSSession]$RemoteSession
        [hashtable]$PoShMonConfiguration
    )

    $mainOutput = Get-InitialOutputWithTimer -SectionHeader "Distributed Cache Status" -OutputHeaders ([ordered]@{ 'Server' = 'Server'; 'Status' = 'Status' })

    $cacheServers = Invoke-RemoteCommand -PoShMonConfiguration $PoShMonConfiguration -ScriptBlock {
                                return Get-SPServiceInstance | ? {($_.service.tostring()) -eq "SPDistributedCacheService Name=AppFabricCachingService"} | select Server, Status
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

        $mainOutput.OutputValues += [pscustomobject]@{
            'Server' = $cacheServer.Server.DisplayName;
            'Status' = $cacheServer.Status.Value;
            'Highlight' = $highlight
        }
    }

    return (Complete-TimedOutput $mainOutput)
}

<#
    $output = Test-SPDistributedCacheHealth $remoteSession -Verbose
#>