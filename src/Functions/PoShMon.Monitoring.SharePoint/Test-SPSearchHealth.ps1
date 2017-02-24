Function Test-SPSearchHealth
{
    [CmdletBinding()]
    param (
        #[System.Management.Automation.Runspaces.PSSession]$RemoteSession
        [hashtable]$PoShMonConfiguration
    )

    Write-Verbose "Getting Search Service App..."

    $searchApp = Invoke-RemoteCommand -PoShMonConfiguration $PoShMonConfiguration -ScriptBlock {
                            Get-SPServiceApplication | Where TypeName -eq 'Search Service Application'
                        }

    $mainOutput = Get-InitialOutputWithTimer `
                                        -SectionHeader "Search Status" `
                                        -OutputHeaders ([ordered]@{ 'ComponentName' = 'Component'; 'ServerName' = 'Server Name'; 'State' = 'State' }) `
                                        -HeaderUrl ($PoShMonConfiguration.SharePoint.CentralAdminUrl + "/SearchAdministration.aspx?appid=" + $searchApp.Id)

    $remoteComponents = Invoke-RemoteCommand -PoShMonConfiguration $PoShMonConfiguration -ScriptBlock {
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
                Write-Verbose ("`t" + $componentTopologyItem.Name + " is in the following state: " + $searchComponentState.State)

                if ($searchComponentState.State -ne "Active")
                {
                    $mainOutput.NoIssuesFound = $false
                    $highlight += 'State'
                    Write-Warning ("`t" + $componentTopologyItem.Name + " is not listed as 'Active'. State: " + $searchComponentState.State)
                }

                $mainOutput.OutputValues += [pscustomobject]@{
                    'ComponentName' = $componentTopologyItem.Name;
                    'ServerName' = $componentTopologyItem.ServerName;
                    'State' = $searchComponentState.State;
                    'Highlight' = $highlight
                }
            }
        }
    }

    return (Complete-TimedOutput $mainOutput)
}
<#
    $output = Test-SPSearchHealth $remoteSession
#>