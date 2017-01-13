Function Test-SearchHealth
{
    [CmdletBinding()]
    param (
        #[System.Management.Automation.Runspaces.PSSession]$RemoteSession
        [hashtable]$PoShMonConfiguration
    )

    $stopWatch = [System.Diagnostics.Stopwatch]::StartNew()

    $mainOutput = Get-InitialOutput -SectionHeader "Search Status" -OutputHeaders ([ordered]@{ 'ComponentName' = 'Component'; 'ServerName' = 'Server Name'; 'State' = 'State' })

    $remoteComponents = Invoke-RemoteCommand -PoShMonConfiguration $PoShMonConfiguration -scriptBlock {
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
                    $mainOutput.NoIssuesFound = $false

                    $highlight += 'State'
                }

                $mainOutput.OutputValues += @{
                    'ComponentName' = $componentTopologyItem.Name;
                    'ServerName' = $componentTopologyItem.ServerName;
                    'State' = $searchComponentState.State;
                    'Highlight' = $highlight
                }
            }
        }
    }

    $stopWatch.Stop()

    $mainOutput.ElapsedTime = $stopWatch.Elapsed

    return $mainOutput
}
<#
    $output = Test-SearchHealth $remoteSession
#>