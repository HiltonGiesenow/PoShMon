Function Resolve-HighCPUWhileSearchRunning
{
    [CmdletBinding()]
    param (
        [hashtable]$PoShMonConfiguration,
        [System.Collections.ArrayList]$TestOutputValues
    )

    Write-Verbose "`tResolving High CPU While Search is running"

    $highCpuOutputValues = $TestOutputValues | Where { $_.SectionHeader -EQ "Server CPU Load Review" -and $_.NoIssuesFound -eq $false }

    if ($highCpuOutputValues.Count -gt 0) # CPU usage is high, let's see why
    {
        $remoteComponents = Invoke-RemoteCommand -PoShMonConfiguration $PoShMonConfiguration -ScriptBlock {
            
            $contentSources = Get-SPEnterpriseSearchServiceApplication | Get-SPEnterpriseSearchCrawlContentSource | Where CrawlState -Like "*crawl*"
            
            $ssa = Get-SPEnterpriseSearchServiceApplication
            $componentTopology = Get-SPEnterpriseSearchComponent -SearchTopology $ssa.ActiveTopology | Select Name, ServerName
            
            return @{
                "ContentSources" = $contentSources;
                "ComponentTopology" = $componentTopology
            }
        }

        if ($remoteComponents.contentSources.Name -ne "" -or $remoteComponents.contentSources.Count -gt 0) #there's at least one content source currently crawling
        {
            $crawlServers = $remoteComponents.componentTopology | Where Name -NotLike 'QueryProcessing*' | Select -ExpandProperty ServerName
            
            $highCpuServers = $highCpuOutputValues.OutputValues | Where { $_.Highlight.Count -gt 0 }

            foreach ($highCpuServer in $highCpuServers)
            {
                if ($crawlServers.Contains($highCpuServer.ServerName))
                    { $highCpuServer.Highlight = @() }
            }
        }
        else # It's not what we thought - a Search crawl running, carry on as usual
        {
            Write-Verbose "`tResolution not applicable, will report as usual"
            return $TestOutputValues
        }
    } else {
        Write-Verbose "`tNothing found to resolve, will report as usual"
    }

    $highCpuServers = $highCpuOutputValues.OutputValues | Where { $_.Highlight.Count -gt 0 }
    if ($highCpuServers.Count -eq 0 -and $highCpuOutputValues.NoIssuesFound -eq $false)
       { $highCpuOutputValues.NoIssuesFound = $true } 

    return $TestOutputValues
}