Function Test-UserProfileSync
{
    [CmdletBinding()]
    param (
        [System.Management.Automation.Runspaces.PSSession]$RemoteSession,
        [hashtable]$PoShMonConfiguration
    )

    $stopWatch = [System.Diagnostics.Stopwatch]::StartNew()

    Write-Verbose "Getting User Profile Sync state..."

    $sectionHeader = "User Profile Sync State"
    $NoIssuesFound = $true
    $outputHeaders = [ordered]@{ 'ManagementAgent' = 'Management Agent'; 'RunProfile' = 'Run Profile'; 'ErrorDetail' = 'ErrorDetail' }
    $outputValues = @()        


    Write-Verbose "`tGetting SharePoint service list..."
    
    $upsServiceInstance = Invoke-Command -Session $remoteSession -ScriptBlock {
                            return Get-SPServiceInstance | Where { $_.TypeName -eq 'User Profile Synchronization Service' -and $_.Status -eq "Online" } | Select Server
                        }
    
    if ($upsServiceInstance -ne $null)
    {
        $runStartDate = (Get-Date).AddMinutes(-$PoShMonConfiguration.General.MinutesToScanHistory).ToString("yyyy-MM-dd")
        $FimRunHistory = get-wmiobject -Namespace "root\MicrosoftIdentityIntegrationServer" -class "MIIS_RunHistory" -ComputerName $upsServiceInstance.Server.DisplayName -Filter "RunStartTime >'$runStartDate'"
        $failedRuns = $FimRunHistory | Where RunStatus -NotIn "success","in-progress"

        if ($failedRuns.Count -gt 0)
        {
            $NoIssuesFound = $false

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

                        $outputItem = @{
                            'ManagementAgent' = $maName;
                            'RunProfile' = $runprofileName ;
                            'ErrorDetail' = $errors.InnerXml;
                        }

                        $outputValues += $outputItem
                    }
                }
            }
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