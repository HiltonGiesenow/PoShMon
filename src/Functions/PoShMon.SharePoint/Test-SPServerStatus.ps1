Function Test-SPServerStatus
{
    [CmdletBinding()]
    param (
        [hashtable]$PoShMonConfiguration
    )

    $stopWatch = [System.Diagnostics.Stopwatch]::StartNew()

    $mainOutput = Get-InitialOutput -SectionHeader "Farm Server Status" -OutputHeaders ([ordered]@{ 'ServerName' = 'Server Name'; 'Role' = 'Role'; 'NeedsUpgrade' = 'Needs Upgrade?'; 'Status' ='Status' })

    #$farm = Get-SPFarm
    #$farm.BuildVersion

    foreach ($ServerName in $PoShMonConfiguration.General.ServerNames) # $farm.Servers
    {
        $server = Get-SPServerForRemoteServer -PoShMonConfiguration $PoShMonConfiguration -ServerName $ServerName

        $highlight = @()

        if ($server.NeedsUpgrade)
        {
            $needsUpgradeValue = "Yes"
            $highlight += 'NeedsUpgrade'
            $mainOutput.NoIssuesFound = $false
            Write-Verbose ($server.DisplayName + " is listed as Needing Upgrade")
        } else {
            $needsUpgradeValue = "No"
        }

        if ($server.Status -ne 'Online')
        {
            $highlight += 'Status'
            $mainOutput.NoIssuesFound = $false
            Write-Verbose ($server.DisplayName + " is not listed as Online")
        }

        $mainOutput.OutputValues += @{
            'ServerName' = $server.DisplayName;
            'NeedsUpgrade' = $needsUpgradeValue;
            'Status' = $server.Status.ToString();
            'Role' = $server.Role.ToString();
            'Highlight' = $highlight
        }
    }

    $stopWatch.Stop()

    $mainOutput.ElapsedTime = $stopWatch.Elapsed

    return $mainOutput
}
<#
    $output = Test-SPServerStatus -Verbose
#>