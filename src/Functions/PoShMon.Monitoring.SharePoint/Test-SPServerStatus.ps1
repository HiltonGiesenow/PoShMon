Function Test-SPServerStatus
{
    [CmdletBinding()]
    param (
        [hashtable]$PoShMonConfiguration
    )

    $mainOutput = Get-InitialOutputWithTimer `
                                        -SectionHeader "Farm Server Status" `
                                        -OutputHeaders ([ordered]@{ 'ServerName' = 'Server Name'; 'Role' = 'Role'; 'NeedsUpgrade' = 'Needs Upgrade?'; 'Status' ='Status' }) `
                                        -HeaderUrl ($PoShMonConfiguration.SharePoint.CentralAdminUrl + "/_admin/FarmServers.aspx")

    foreach ($ServerName in $PoShMonConfiguration.General.ServerNames) # $farm.Servers
    {
        $server = Get-SPServerForRemoteServer -PoShMonConfiguration $PoShMonConfiguration -ServerName $ServerName

        $highlight = @()

        Write-Verbose "`t$($server.DisplayName) : $($server.Status) : $($server.NeedsUpgrade)"

        if ($server.NeedsUpgrade)
        {
            $needsUpgradeValue = "Yes"
            $highlight += 'NeedsUpgrade'
            $mainOutput.NoIssuesFound = $false
            Write-Warning "`t$($server.DisplayName) is listed as Needing Upgrade"
        } else {
            $needsUpgradeValue = "No"
        }

        if ($server.Status -ne 'Online')
        {
            $highlight += 'Status'
            $mainOutput.NoIssuesFound = $false
            Write-Warning "`t$($server.DisplayName) is not listed as Online. Status: $($server.Status)"
        }

        $mainOutput.OutputValues += [pscustomobject]@{
            'ServerName' = $server.DisplayName;
            'NeedsUpgrade' = $needsUpgradeValue;
            'Status' = $server.Status.ToString();
            'Role' = $server.Role.ToString();
            'Highlight' = $highlight
        }
    }

    return (Complete-TimedOutput $mainOutput)
}
<#
    $output = Test-SPServerStatus -Verbose
#>