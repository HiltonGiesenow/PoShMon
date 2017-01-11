Function Test-FarmHealth
{
    [CmdletBinding()]
    param (
        [System.Management.Automation.Runspaces.PSSession]$RemoteSession
    )

    $stopWatch = [System.Diagnostics.Stopwatch]::StartNew()

    $mainOutput = Get-InitialOutput -SectionHeader "Farm Overview" -OutputHeaders ([ordered]@{ 'ConfigDB' = 'Config DB Name'; 'BuildVersion' = 'Build Version'; 'Status' = 'Status'; 'NeedsUpgrade' = 'Needs Upgrade?' })

    $farm = Invoke-Command -Session $RemoteSession -ScriptBlock {
        return Get-SPFarm | Select Name, BuildVersion, Status, NeedsUpgrade
    }

    if ($farm.Status.Value -ne 'Online')
    {
        $mainOutput.NoIssuesFound = $false
        $highlight += 'Status'
        Write-Host "Farm Status is $($farm.Status.Value)" -ForegroundColor Yellow
    }
    if ($farm.NeedsUpgrade -eq $true)
    {
        $mainOutput.NoIssuesFound = $false
        $highlight += 'NeedsUpgrade'
        Write-Host "Farm needs upgrade"  -ForegroundColor Yellow       
    }
    
    $mainOutput.OutputValues += @{
        'ConfigDB' = $farm.Name;
        'BuildVersion' = $farm.BuildVersion;
        'Status' = $farm.Status.Value;
        'NeedsUpgrade' = if ($farm.NeedsUpgrade) { "Yes" } else { "No" };
        'Highlight' = $highlight
    }

    $stopWatch.Stop()

    $mainOutput.ElapsedTime = $stopWatch.Elapsed

    return $mainOutput
}
<#
    $output = Test-SearchHealth $remoteSession
#>