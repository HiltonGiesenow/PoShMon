Function Test-SPServerStatus
{
    [CmdletBinding()]
    param (
        [hashtable]$PoShMonConfiguration
    )

    $stopWatch = [System.Diagnostics.Stopwatch]::StartNew()

    Write-Verbose "Testing Server Statuses..."

    $sectionHeader = "Farm Server Status"
    $NoIssuesFound = $true
    $outputHeaders = [ordered]@{ 'ServerName' = 'Server Name'; 'Role' = 'Role'; 'NeedsUpgrade' = 'Needs Upgrade?'; 'Status' ='Status' }
    $outputValues = @()

    #$farm = Get-SPFarm
    #$farm.BuildVersion

    foreach ($ServerName in $PoShMonConfiguration.General.ServerNames) # $farm.Servers
    {
        try {
            $remoteSession = Connect-RemoteSession -ServerName $ServerName -ConfigurationName $PoShMonConfiguration.General.ConfigurationName

            $server = Invoke-Command -Session $remoteSession -ScriptBlock {
                                        Add-PSSnapin Microsoft.SharePoint.PowerShell
                                        Get-SPServer | Where Address -eq $env:COMPUTERNAME
                                    }
        } finally {
            Disconnect-RemoteSession $remoteSession
        }

        $highlight = @()

        if ($server.NeedsUpgrade)
        {
            $needsUpgradeValue = "Yes"
            $highlight += 'NeedsUpgrade'
            $NoIssuesFound = $false
            Write-Verbose ($server.DisplayName + " is listed as Needing Upgrade")
        } else {
            $needsUpgradeValue = "No"
        }

        if ($server.Status -ne 'Online')
        {
            $highlight += 'Status'
            $NoIssuesFound = $false
            Write-Verbose ($server.DisplayName + " is not listed as Online")
        }

        $outputItem = @{
            'ServerName' = $server.DisplayName;
            'NeedsUpgrade' = $needsUpgradeValue;
            'Status' = $server.Status.ToString();
            'Role' = $server.Role.ToString();
            'Highlight' = $highlight
        }

        $outputValues += $outputItem

        if ($server.Status -ne "Online")
        {
            $NoIssuesFound = $false

            Write-Verbose ($server.DisplayName + " is in status " + $server.Status)
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
    $output = Test-SPServerStatus -Verbose
#>