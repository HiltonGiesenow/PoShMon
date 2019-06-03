Function Test-EventLogs
{
    [CmdletBinding()]
    param (
        [hashtable]$PoShMonConfiguration
    )

    $allTestsOutput = @()

    foreach ($SeverityCode in $PoShMonConfiguration.OperatingSystem.EventLogCodes)
    {   
        $mainOutput = Get-InitialOutputWithTimer -SectionHeader "$SeverityCode Event Log Issues" -GroupBy 'ServerName' -OutputHeaders ([ordered]@{ 'EventID' = 'Event ID'; 'InstanceCount' = 'Count'; 'Source' = 'Source'; 'User' = 'User'; 'Timestamp' = 'Timestamp'; 'Message' ='Message' })

        $wmiStartDate = (Get-Date).AddMinutes(-$PoShMonConfiguration.General.MinutesToScanHistory)
        $wmidate = New-Object -com Wbemscripting.swbemdatetime
        $wmidate.SetVarDate($wmiStartDate, $true)
        $wmiStartDateWmi = $wmidate.value

        foreach ($serverName in $PoShMonConfiguration.General.ServerNames)
        {
			$serverHasEntries = $false
        
            $eventLogEntryGroups = Get-GroupedEventLogItemsBySeverity -ComputerName $serverName -SeverityCode $SeverityCode -WmiStartDate $wmiStartDateWmi

            Write-Verbose "`t$serverName"

            if ($eventLogEntryGroups.Count -gt 0)
            {
                foreach ($eventLogEntryGroup in $eventLogEntryGroups)
                {
                    $currentEntry = $eventLogEntryGroup.Group[0]

                    $markedForIgnore = $false
                    if ($PoShMonConfiguration.OperatingSystem.EventLogIgnores -ne $null)
                    {
                        foreach ($EventLogIgnore in $PoShMonConfiguration.OperatingSystem.EventLogIgnores)
                        {
                            if ($EventLogIgnore.EventID -eq $currentEntry.EventCode -and ($EventLogIgnore.IgnoreIfLessThan -eq 0 -or $eventLogEntryGroup.Count -lt $EventLogIgnore.IgnoreIfLessThan))
                                { $markedForIgnore = $true }
                        }
                    }

					#if ($EventIDIgnoreList.Count -eq 0 -or $EventIDIgnoreList.ContainsKey($currentEntry.EventCode) -eq $false)
					#if ($PoShMonConfiguration.OperatingSystem.EventIDIgnoreList.Count -eq 0 -or `
                    # 	$PoShMonConfiguration.OperatingSystem.EventIDIgnoreList.ContainsKey($currentEntry.EventCode.ToString()) -eq $false)
                    if ($markedForIgnore -eq $false)
                    {
						$mainOutput.NoIssuesFound = $false
						$serverHasEntries = $true

                        Write-Warning ("`t`t" + $currentEntry.EventCode.ToString() + ' : ' + $eventLogEntryGroup.Count + ' : ' + $currentEntry.SourceName + ' : ' + $currentEntry.User + ' : ' + $currentEntry.ConvertToDateTime($currentEntry.TimeGenerated) + ' - ' + $currentEntry.Message)
                
                        # Depending on what happened, the Message can be empty so 'InsertionStrings' has the details
                        $message = if ([String]::IsNullOrEmpty($currentEntry.Message) -eq $false) { $currentEntry.Message } else { $currentEntry.InsertionStrings -join ", " }

                        $mainOutput.OutputValues += [pscustomobject]@{
                                        'ServerName' = $serverName;
                                        'EventID' = $currentEntry.EventCode;
                                        'InstanceCount' = $eventLogEntryGroup.Count;
                                        'Source' = $currentEntry.SourceName;
                                        'User' = $currentEntry.User;
                                        'Timestamp' = $currentEntry.ConvertToDateTime($currentEntry.TimeGenerated);
                                        'Message' = $message
                                    }
                    }
                }
            }

            if ($serverHasEntries -eq $false)
            {
                Write-Verbose "`t`tNo Entries Found In Time Specified"

                $mainOutput.OutputValues += [pscustomobject]@{
                                'ServerName' = $serverName;
                }
            }
        }

        $allTestsOutput += (Complete-TimedOutput $mainOutput)
    }

    return $allTestsOutput
}