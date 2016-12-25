Function Test-EventLogs
{
    [CmdletBinding()]
    param (
        [string[]]$ServerNames = @(),
        [int]$MinutesToScanHistory = 1440, # one day
        [string]$SeverityCode = 'Critical',
        [hashtable]$EventIDIgnoreList = @{}
    )
   
    $stopWatch = [System.Diagnostics.Stopwatch]::StartNew()
   
    $NoIssuesFound = $true
    $sectionHeader = "$SeverityCode Event Log Issues"
    $outputHeaders = @{ 'EventID' = 'Event ID'; 'InstanceCount' = 'Count'; 'Source' = 'Source'; 'User' = 'User'; 'Timestamp' = 'Timestamp'; 'Message' ='Message' }
    $outputValues = @()

    $wmiStartDate = (Get-Date).AddMinutes(-$MinutesToScanHistory) #.ToUniversalTime()
    $wmidate = new-object -com Wbemscripting.swbemdatetime
    $wmidate.SetVarDate($wmiStartDate, $true)
    $wmiStartDateWmi = $wmidate.value

    Write-Verbose "Getting $SeverityCode Event Log Issues..."

    foreach ($serverName in $ServerNames)
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
                    $NoIssuesFound = $false

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

            $groupedoutputItem = @{
                                'GroupName' = $serverName
                                'GroupOutputValues' = $itemOutputValues
                            }

            $outputValues += $groupedoutputItem
        }

        if ($NoIssuesFound)
        {
            Write-Verbose "`tNone"
            $groupedoutputItem = @{
                                'GroupName' = $serverName
                                'GroupOutputValues' = @()
                            }

            $outputValues += $groupedoutputItem
        }
    }

    $stopWatch.Stop()

    return @{
        "SectionHeader" = $sectionHeader;
        "NoIssuesFound" = $NoIssuesFound;
        "OutputHeaders" = $outputHeaders;
        "OutputValues" = $outputValues;
        "ElapsedTime" = $stopWatch.Elapsed
        }
}