Function Test-SPJobHealth
{
    [CmdletBinding()]
    param (
        #[System.Management.Automation.Runspaces.PSSession]$RemoteSession,
        [hashtable]$PoShMonConfiguration
    )


    $mainOutput = Get-InitialOutputWithTimer -SectionHeader "Failing Timer Jobs" -OutputHeaders ([ordered]@{ 'JobDefinitionTitle' = 'Job Definition Title'; 'EndTime' = 'End Time'; 'ServerName' = 'Server Name'; 'WebApplicationName' = 'Web Application Name'; 'ErrorMessage' ='Error Message' })

    $startDate = (Get-Date).AddMinutes(-$PoShMonConfiguration.General.MinutesToScanHistory) #.ToUniversalTime()

    $jobHistoryEntries = Invoke-RemoteCommand -PoShMonConfiguration $PoShMonConfiguration -ScriptBlock {
                                param($StartDate)

                                $farm = Get-SPFarm
                                $timerJobService = $farm.TimerService

                                $jobHistoryEntries = $timerJobService.JobHistoryEntries | Where-Object { $_.Status -eq "Failed" -and $_.StartTime -gt $StartDate }

                                return $jobHistoryEntries
                            } -ArgumentList $startDate

    if ($jobHistoryEntries.Count -gt 0)
    {
        $mainOutput.NoIssuesFound = $false

        foreach ($jobHistoryEntry in $jobHistoryEntries)
        {
            Write-Warning ("`t" + $jobHistoryEntry.JobDefinitionTitle + " at " + $jobHistoryEntry.EndTime + " on " + $jobHistoryEntry.ServerName + " for " + $jobHistoryEntry.WebApplicationName + " : " + $jobHistoryEntry.ErrorMessage)
            
            $mainOutput.OutputValues += @{
                'JobDefinitionTitle' = $jobHistoryEntry.JobDefinitionTitle;
                'EndTime' = $jobHistoryEntry.EndTime;
                'ServerName' = $jobHistoryEntry.ServerName;
                'WebApplicationName' = $jobHistoryEntry.WebApplicationName;
                'ErrorMessage' = $jobHistoryEntry.ErrorMessage
            }
        }
    }

    return (Complete-TimedOutput $mainOutput)
}
<#
    $output = Test-SPJobHealth -RemoteSession $remoteSession -MinutesToScanHistory 2000 -Verbose
#>