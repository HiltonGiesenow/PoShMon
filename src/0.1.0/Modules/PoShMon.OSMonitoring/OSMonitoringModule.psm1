Function Get-EventLogItemsBySeverity
{
    param (
        [string]$ComputerName,
        [string]$SeverityCode = "Warning",
        $WmiStartDate
    )

   $events = Get-WmiObject win32_NTLogEvent -ComputerName $ComputerName -filter "(logfile='Application') AND (Type ='$severityCode') And TimeGenerated > '$wmiStartDate'"

   return $events
}

Function Get-GroupedEventLogItemsBySeverity
{
    param (
        [string]$ComputerName,
        [string]$SeverityCode = "Warning",
        $WmiStartDate
    )

   $events = Get-WmiObject win32_NTLogEvent -ComputerName $ComputerName -filter "(logfile='Application') AND (Type ='$severityCode') And TimeGenerated > '$wmiStartDate'" | Group-Object EventCode, Message

   return $events
}

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

Function Test-DriveSpace
{
    [CmdletBinding()]
    param (
        [string[]]$ServerNames
    )

    $threshhold = 10000

    $stopWatch = [System.Diagnostics.Stopwatch]::StartNew()

    $sectionHeader = "Harddrive Space Review"
    $NoIssuesFound = $true
    $outputHeaders = @{ 'DriveLetter' = 'Drive Letter'; 'TotalSpace' = 'Total Space (GB)'; 'FreeSpace' = 'Free Space (GB)' }
    $outputValues = @()

    Write-Verbose "Getting Server Drive Space..."

    foreach ($serverName in $ServerNames)
    {
        Write-Verbose $serverName

        $itemOutputValues = @()
    
        $serverDriveSpace = Get-WmiObject win32_logicaldisk -Computername $serverName

        foreach ($drive in ($serverDriveSpace | Where DriveType -eq 3))
        {
            $totalSpace = $drive.Size | Format-Gigs 
            $freeSpace = $drive.FreeSpace | Format-Gigs 
            $highlight = @()

            if ([int]$freeSpace -lt $threshhold)
            {
                $NoIssuesFound = $false
                $highlight += "FreeSpace"
            }

            Write-Verbose ("`t" + $drive.DeviceID + " : " + $totalSpace + " : " + $freeSpace)

            $outputItem = @{
                'DriveLetter' = $drive.DeviceID;
                'TotalSpace' = $totalSpace;
                'FreeSpace' = $freeSpace;
                'Highlight' = $highlight
            }

            $itemOutputValues += $outputItem
        }

        $groupedoutputItem = @{
                    'GroupName' = $serverName
                    'GroupOutputValues' = $itemOutputValues
                }

        $outputValues += $groupedoutputItem
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

Function Test-ServiceState
{
    [CmdletBinding()]
    param (
        [string[]]$ServerNames,
        [string[]]$Services,
        [string]$ServiceState = "Running"
    )

    $sectionHeader = "Windows Service State"
    $NoIssuesFound = $true
    $outputHeaders = @{ 'DisplayName' = 'Display Name'; 'Name' = 'Name'; 'Status' = 'Status' }
    $outputValues = @()

    Write-Verbose "Getting Windows Service State..."

    $servicesFound = Get-Service -ComputerName $ServerNames

    foreach ($serverName in $ServerNames) # should we be reporting by server name or by service?
    {
        Write-Verbose "`t Checking $serverName..."
        
        $serviceFoundOnServer = $servicesFound | Where MachineName -eq $serverName

        foreach ($service in $Services)
        {
            Write-Verbose "`t`t Checking '$service'..."

            $itemOutputValues = @()

            $serviceFound = $serviceFoundOnServer | Where Name -eq $service

            if ($serviceFound -eq $null)
            {
                $NoIssuesFound = $false
                $highlight += "Status"

                Write-Host "Service '$service' on $serverName Not Found!" -ForegroundColor Red

                $outputItem = @{
                    'DisplayName' = $service;
                    'Name' = "[Not Found]";
                    'State' = "[Not Found]";
                }
            } else {
                if ($ServiceState -ne $serviceFound.Status)
                {
                    $NoIssuesFound = $false
                    $highlight += "Status"

                    Write-Host "$service' on $serverName state incorrect - expected $ServiceState" -ForegroundColor Red
                } else {
                    Write-Verbose "`t`t'$service' found and in correct state"
                }

                $outputItem = @{
                    'DisplayName' = $service;
                    'Name' = $serviceFound.Name;
                    'State' = $serviceFound.State;
                }
            }

            $itemOutputValues += $outputItem
        }

        $groupedoutputItem = @{
                'GroupName' = $serverName
                'GroupOutputValues' = $itemOutputValues
            }

        $outputValues += $groupedoutputItem
    }

    return @{
        "SectionHeader" = $sectionHeader;
        "NoIssuesFound" = $NoIssuesFound;
        "OutputHeaders" = $outputHeaders;
        "OutputValues" = $outputValues
        }
}

Function Test-ServiceStatePartial
{
    [CmdletBinding()]
    param (
        [string[]]$ServerName,
        [string[]]$Services,
        [string]$ServiceState = "Running"
    )

    $NoIssuesFound = $true

    $serviceFoundOnServer = Get-Service -ComputerName $ServerName

    $itemOutputValues = @()

    foreach ($service in $Services)
    {
        Write-Verbose "`t`t Checking '$service'..."

        $serviceFound = $serviceFoundOnServer | Where Name -eq $service

        $highlight = ""

        if ($serviceFound -eq $null)
        {
            $NoIssuesFound = $false
            $highlight += "Status"

            Write-Host "Service '$service' on $serverName Not Found!" -ForegroundColor Red

            $outputItem = @{
                'DisplayName' = "[Not Found]";
                'Name' = $service;
                'Status' = "[Not Found]";
                'Highlight' = $highlight
            }
        } else {
            if ($ServiceState -ne $serviceFound.Status)
            {
                $NoIssuesFound = $false
                $highlight += "Status"

                Write-Host "'$service' on $serverName state incorrect - expected $ServiceState" -ForegroundColor Red
            } else {
                Write-Verbose "`t`t'$service' found and in correct state"
            }

            $outputItem = @{
                'DisplayName' = $serviceFound.DisplayName;
                'Name' = $serviceFound.Name;
                'Status' = $serviceFound.Status;
                'Highlight' = $highlight
            }
        }

        $itemOutputValues += $outputItem
    }

    $groupedoutputItem = @{
            'GroupName' = $serverName
            'GroupOutputValues' = $itemOutputValues
            'NoIssuesFound' = $NoIssuesFound
        }

    return $groupedoutputItem
}

Function Invoke-OSMonitoring
{
    [CmdletBinding()]
    Param(
        #[parameter(Mandatory=$true, HelpMessage=”Path to file”)]
        [string]$EnvironmentName = "Environment",
        [int]$MinutesToScanHistory = 15,
        [string[]]$ServerNames = @(),
        [string[]]$MailToList = @(),
        [string[]]$EventLogCodes = 'Critical',
        [hashtable]$EventIDIgnoreList = @{},
        [bool]$SendEmail = $true,
        [bool]$SendEmailOnlyOnFailure = $false,
        [string]$MailFrom,
        [string]$SMTPAddress
    )

    $stopWatch = [System.Diagnostics.Stopwatch]::StartNew()

    $outputValues = @()

    # Event Logs
    foreach ($eventLogCode in $EventLogCodes)
        { $outputValues += Test-EventLogs -ServerNames $ServerNames -MinutesToScanHistory $MinutesToScanHistory -SeverityCode $eventLogCode }

    # Drive Space
    $outputValues += Test-DriveSpace -ServerNames $ServerNames

    $stopWatch.Stop()

    Confirm-SendMonitoringEmail -TestOutputValues $outputValues -SendEmailOnlyOnFailure $SendEmailOnlyOnFailure -SendEmail $SendEmail `
        -EnvironmentName $EnvironmentName -MailToList $MailToList -MailFrom $MailFrom -SMTPAddress $SMTPAddress -TotalElapsedTime $stopWatch.Elapsed

    return $outputValues
}