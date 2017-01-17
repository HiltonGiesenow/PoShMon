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
        $highlight = @()

        if ($spDatabase.NeedsUpgrade)
        {
            $mainOutput.NoIssuesFound = $false

            Write-Verbose ($spDatabase.DisplayName + " (" + $spDatabase.ApplicationName + ") is listed as Needing Upgrade")

            $highlight += 'NeedsUpgrade'
        }

        $mainOutput.OutputValues += @{
            'DatabaseName' = $spDatabase.DisplayName;
            'NeedsUpgrade' = &{if($spDatabase.NeedsUpgrade) {"Yes"} else {"No"}};
            'Size' = ($spDatabase.DiskSizeRequired/1GB).ToString(".00");
            'Highlight' = $highlight
        }
    }

    return (Complete-TimedOutput $mainOutput)
}
<#
    $output = Test-DatabaseHealth $remoteSession -Verbose
#>