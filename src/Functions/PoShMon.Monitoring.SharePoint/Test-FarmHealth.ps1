Function Test-FarmHealth
{
    [CmdletBinding()]
    param (
        #[System.Management.Automation.Runspaces.PSSession]$RemoteSession
        [hashtable]$PoShMonConfiguration
    )

    $mainOutput = Get-InitialOutputWithTimer -SectionHeader "Farm Overview" -OutputHeaders ([ordered]@{ 'ConfigDB' = 'Config DB Name'; 'BuildVersion' = 'Build Version'; 'Status' = 'Status'; 'NeedsUpgrade' = 'Needs Upgrade?' })

    $farm = Invoke-RemoteCommand -PoShMonConfiguration $PoShMonConfiguration -ScriptBlock {
        return Get-SPFarm | Select Name, BuildVersion, Status, NeedsUpgrade
    }

    if ($farm.Status.Value -ne 'Online')
    {
        $mainOutput.NoIssuesFound = $false
        $highlight += 'Status'
        Write-Warning "Farm Status is $($farm.Status.Value)"
    }
    if ($farm.NeedsUpgrade -eq $true)
    {
        $mainOutput.NoIssuesFound = $false
        $highlight += 'NeedsUpgrade'
        Write-Warning "Farm needs upgrade"      
    }
    
    $mainOutput.OutputValues += [pscustomobject]@{
        'ConfigDB' = $farm.Name;
        'BuildVersion' = $farm.BuildVersion;
        'Status' = $farm.Status.Value;
        'NeedsUpgrade' = if ($farm.NeedsUpgrade) { "Yes" } else { "No" };
        'Highlight' = $highlight
    }

    return (Complete-TimedOutput $mainOutput)
}
<#
    $output = Test-SPSearchHealth $remoteSession
#>