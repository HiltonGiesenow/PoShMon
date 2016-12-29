Function Test-DistributedCacheStatus
{
    [CmdletBinding()]
    param (
        [System.Management.Automation.Runspaces.PSSession]$RemoteSession
    )

    $stopWatch = [System.Diagnostics.Stopwatch]::StartNew()

    Write-Verbose "Testing Distributed Cache Health..."
    $sectionHeader = "Distributed Cache Status"
    $NoIssuesFound = $true
    $outputHeaders = @{ 'Server' = 'Server'; 'Status' = 'Status' }
    $outputValues = @()

    $cacheServers = Invoke-Command -Session $RemoteSession -ScriptBlock {
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

        if ($cacheServer.Status.Value -ne 'Online')
        {
            $NoIssuesFound = $false

            Write-Verbose ($cacheServer.Server.DisplayName + " is listed as " + $cacheServer.Status)

            $highlight += 'Status'
        }

        $outputItem = @{
            'Server' = $cacheServer.Server.DisplayName;
            'Status' = $cacheServer.Status.Value;
            'Highlight' = $highlight
        }

        $outputValues += $outputItem
    }

    $stopWatch.Stop()

    return @{
        "SectionHeader" = $sectionHeader;
        "NoIssuesFound" = $NoIssuesFound;
        "OutputHeaders" = $outputHeaders;
        "OutputValues" = $outputValues;
        "ElapsedTime" = $stopWatch.Elapsed;
        }
}

<#
    $output = Test-DistributedCacheStatus $remoteSession -Verbose
#>