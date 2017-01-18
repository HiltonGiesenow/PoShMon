Function Test-EventLogs
{
    [CmdletBinding()]
    param (
        [hashtable]$PoShMonConfiguration
    )

    $allTestsOutput = @()

    foreach ($SeverityCode in $PoShMonConfiguration.OperatingSystem.EventLogCodes)
    {   
        $mainOutput = Get-InitialOutputWithTimer -SectionHeader "$SeverityCode Event Log Issues" -OutputHeaders ([ordered]@{ 'EventID' = 'Event ID'; 'InstanceCount' = 'Count'; 'Source' = 'Source'; 'User' = 'User'; 'Timestamp' = 'Timestamp'; 'Message' ='Message' })

        $wmiStartDate = (Get-Date).AddMinutes(-$PoShMonConfiguration.General.MinutesToScanHistory)
        $wmidate = new-object -com Wbemscripting.swbemdatetime
        $wmidate.SetVarDate($wmiStartDate, $true)
        $wmiStartDateWmi = $wmidate.value

        foreach ($serverName in $PoShMonConfiguration.General.ServerNames)
        {
            $itemOutputValues = @()
        
            $eventLogEntryGroups = Get-GroupedEventLogItemsBySeverity -ComputerName $serverName -SeverityCode $SeverityCode -WmiStartDate $wmiStartDateWmi

            Write-Verbose $serverName

            if ($eventLogEntryGroups.Count -gt 0)
            {
                foreach ($eventLogEntryGroup in $eventLogEntryGroups)
                {
                    $currentEntry = $eventLogEntryGroup.Group[0]

                    if ($EventIDIgnoreList.Count -eq 0 -or $EventIDIgnoreList.ContainsKey($currentEntry.EventCode) -eq $false)
                    {
                        $mainOutput.NoIssuesFound = $false

                        Write-Verbose ($currentEntry.EventCode.ToString() + ' (' + $eventLogEntryGroup.Count + ', ' + $currentEntry.SourceName + ', ' + $currentEntry.User + ') : ' + $currentEntry.ConvertToDateTime($currentEntry.TimeGenerated) + ' - ' + $currentEntry.Message)
                
                        $outputItem = @{
                                        'EventID' = $currentEntry.EventCode;
                                        'InstanceCount' = $eventLogEntryGroup.Count;
                                        'Source' = $currentEntry.SourceName;
                                        'User' = $currentEntry.User;
                                        'Timestamp' = $currentEntry.ConvertToDateTime($currentEntry.TimeGenerated);
                                        'Message' = $currentEntry.Message
                                    }

                        $itemOutputValues += $outputItem
                    }
                }

                $mainOutput.OutputValues += @{
                                    'GroupName' = $serverName
                                    'GroupOutputValues' = $itemOutputValues
                                }
            }

            if ($mainOutput.NoIssuesFound)
            {
                Write-Verbose "`tNone"
                $mainOutput.OutputValues += @{
                                    'GroupName' = $serverName
                                    'GroupOutputValues' = @()
                                }
            }
        }

        $allTestsOutput += (Complete-TimedOutput $mainOutput)
    }

    return $allTestsOutput
}