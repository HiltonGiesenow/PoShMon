Function Test-SPDatabaseHealth
{
    [CmdletBinding()]
    param (
        #[System.Management.Automation.Runspaces.PSSession]$RemoteSession
        [hashtable]$PoShMonConfiguration
    )

    $mainOutput = Get-InitialOutputWithTimer -SectionHeader "Database Status" -OutputHeaders ([ordered]@{ 'DatabaseName' = 'Database Name'; 'Size' = 'Size (GB)'; 'NeedsUpgrade' = 'Needs Upgrade?' })

    $spDatabases = Invoke-RemoteCommand -PoShMonConfiguration $PoShMonConfiguration -ScriptBlock {
                        return Get-SPDatabase | Sort DiskSizeRequired -Descending
                    }

    foreach ($spDatabase in $spDatabases)
    {
        $needsUpgradeText = if ($spDatabase.NeedsUpgrade) {"Yes"} else {"No"}
        $SizeText = ($spDatabase.DiskSizeRequired/1GB).ToString(".00")

        Write-Verbose "`t$($spDatabase.DisplayName) : $needsUpgradeText : $SizeText GB"

        $highlight = @()

        if ($spDatabase.NeedsUpgrade)
        {
            $mainOutput.NoIssuesFound = $false
            $highlight += 'NeedsUpgrade'
            Write-Warning ("`t" + $spDatabase.DisplayName + " (" + $spDatabase.ApplicationName + ") is listed as Needing Upgrade")
        }

        $mainOutput.OutputValues += [pscustomobject]@{
            'DatabaseName' = $spDatabase.DisplayName;
            'NeedsUpgrade' = $needsUpgradeText
            'Size' = $SizeText;
            'Highlight' = $highlight
        }
    }

    return (Complete-TimedOutput $mainOutput)
}
<#
    $output = Test-SPDatabaseHealth $remoteSession -Verbose
#>