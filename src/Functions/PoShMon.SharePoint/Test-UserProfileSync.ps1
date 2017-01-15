Function Test-UserProfileSync
{
    [CmdletBinding()]
    param (
        #[System.Management.Automation.Runspaces.PSSession]$RemoteSession,
        [hashtable]$PoShMonConfiguration
    )

    $stopWatch = [System.Diagnostics.Stopwatch]::StartNew()
      
    $mainOutput = Get-InitialOutput -SectionHeader "User Profile Sync State" -OutputHeaders ([ordered]@{ 'ManagementAgent' = 'Management Agent'; 'RunProfile' = 'Run Profile'; 'RunStartTime' = 'Run Start Time'; 'ErrorDetail' = 'ErrorDetail' })

    Write-Verbose "`tGetting SharePoint service list..."
    
    $upsServiceInstance = Invoke-RemoteCommand -PoShMonConfiguration $PoShMonConfiguration -ScriptBlock {
                            return Get-SPServiceInstance | Where { $_.TypeName -eq 'User Profile Synchronization Service' -and $_.Status -eq "Online" } | Select Server
                        }
    
    if ($upsServiceInstance -ne $null)
    {
        $runStartDate = (Get-Date).AddMinutes(-$PoShMonConfiguration.General.MinutesToScanHistory).ToString("yyyy-MM-dd HH:mm:ss")
        $FimRunHistory = Get-WmiObject -Namespace "root\MicrosoftIdentityIntegrationServer" -class "MIIS_RunHistory" -ComputerName $upsServiceInstance.Server.DisplayName -Filter "RunStartTime >'$runStartDate'"
        $failedRuns = $FimRunHistory | Where RunStatus -NotIn "success","in-progress"

        if ($failedRuns.Count -gt 0)
        {
            $mainOutput.NoIssuesFound = $false

            foreach($failedRun in $failedRuns)
            {
                [xml]$failedRunXml = $failedRun.RunDetails().ReturnValue

                $maName = $failedRunXml."run-history"."run-details"."ma-name"
                $runprofileName = $failedRunXml."run-history"."run-details"."run-profile-name"

                $steps = $failedRunXml."run-history"."run-details"."step-details"

                foreach($step in $steps)
                {
                    if ($step."step-result" -ne "success")
                    {
                        $stepNumber = $step."step-number"
                        $stepResult = $step."step-result"
                        $connectionErrors = $step."ma-connection"
                        $syncErrors = $step."synchronization-errors"

                        if ($connectionErrors -ne "") { $errors = $connectionErrors } else { $errors = $syncErrors }
                        
                        Write-Host "` Step $stepNumber has status of $stepResult : $($errors.InnerXml)"

                        $mainOutput.OutputValues += @{
                            'ManagementAgent' = $maName;
                            'RunProfile' = $runprofileName;
                            'RunStartTime' = [DateTime]::Parse($failedRun.RunStartTime).ToString("yyyy-MM-dd HH:mm:ss")
                            'ErrorDetail' = $errors.InnerXml;
                        }
                    }
                }
            }
        }
    }

    $stopWatch.Stop()

    $mainOutput.ElapsedTime = $stopWatch.Elapsed

    return $mainOutput
}