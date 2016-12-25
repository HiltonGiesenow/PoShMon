Function Test-DatabaseHealth
{
    [CmdletBinding()]
    param (
        [System.Management.Automation.Runspaces.PSSession]$RemoteSession
    )

    $stopWatch = [System.Diagnostics.Stopwatch]::StartNew()

    Write-Verbose "Testing Database Health..."

    $sectionHeader = "Database Status"
    $NoIssuesFound = $true
    $outputHeaders = @{ 'DatabaseName' = 'Database Name'; 'Size' = 'Size (MB)'; 'NeedsUpgrade' = 'Needs Upgrade?' }
    $outputValues = @()

    $spDatabases = Invoke-Command -Session $RemoteSession -ScriptBlock {
                                return Get-SPDatabase
                            }

    foreach ($spDatabase in $spDatabases)
    {
        $highlight = @()

        if ($spDatabase.NeedsUpgrade)
        {
            $NoIssuesFound = $false

            Write-Verbose ($spDatabase.DisplayName + " (" + $spDatabase.ApplicationName + ") is listed as Needing Upgrade")

            $highlight += 'NeedsUpgrade'
        }

        $outputItem = @{
            'DatabaseName' = $spDatabase.DisplayName;
            'NeedsUpgrade' = &{if($spDatabase.NeedsUpgrade) {"Yes"} else {"No"}};
            'Size' = ($spDatabase.DiskSizeRequired | Format-Gigs);
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
    $output = Test-DatabaseHealth $remoteSession -Verbose
#>