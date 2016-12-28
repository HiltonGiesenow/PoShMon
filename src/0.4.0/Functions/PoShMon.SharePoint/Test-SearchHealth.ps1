Function Test-SearchHealth
{
    [CmdletBinding()]
    param (
        [System.Management.Automation.Runspaces.PSSession]$RemoteSession
    )

    $stopWatch = [System.Diagnostics.Stopwatch]::StartNew()

    Write-Verbose "Testing Search Health..."

    $sectionHeader = "Search Status"
    $NoIssuesFound = $true
    $outputHeaders = @{ 'ComponentName' = 'Component'; 'ServerName' = 'Server Name'; 'State' = 'State' }
    $outputValues = @()

    $remoteComponents = Invoke-Command -Session $RemoteSession -ScriptBlock {
        $ssa = Get-SPEnterpriseSearchServiceApplication

        $searchComponentStates = Get-SPEnterpriseSearchStatus -SearchApplication $ssa -Detailed #| Where State -ne "Active"

        $componentTopology = Get-SPEnterpriseSearchComponent -SearchTopology $ssa.ActiveTopology | Select Name,ServerName

        return @{
            "SearchComponentStates" = $searchComponentStates;
            "ComponentTopology" = $componentTopology
        }
    }

    foreach ($searchComponentState in $remoteComponents.SearchComponentStates)
    {
        $highlight = @()

        foreach ($componentTopologyItem in $remoteComponents.ComponentTopology)
        {
            if ($componentTopologyItem.Name.ToLower() -eq $searchComponentState.Name.ToLower())
            {
                Write-Verbose ($componentTopologyItem.Name + " is in the following state: " + $searchComponentState.State)

                if ($searchComponentState.State -ne "Active")
                {
                    $NoIssuesFound = $false

                    $highlight += 'State'
                }

                $outputItem = @{
                    'ComponentName' = $componentTopologyItem.Name;
                    'ServerName' = $componentTopologyItem.ServerName;
                    'State' = $searchComponentState.State;
                    'Highlight' = $highlight
                }

                $outputValues += $outputItem
            }
        }
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
    $output = Test-SearchHealth $remoteSession
#>