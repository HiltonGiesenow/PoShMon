Function Test-ComputerTime
{
    [CmdletBinding()]
    param (
        [hashtable]$PoShMonConfiguration
    )

    #if ($PoShMonConfiguration.OperatingSystem -eq $null) { throw "'OperatingSystem' configuration not set properly on PoShMonConfiguration parameter." }

    $mainOutput = Get-InitialOutputWithTimer -SectionHeader "Server Clock Review" -OutputHeaders ([ordered]@{ 'ServerName' = 'Server Name'; 'CurrentTime' = 'Current Time'; 'LastBootUptime' = 'Last Boot Time'; })

    $results = Get-WmiObject Win32_OperatingSystem -Computername $PoShMonConfiguration.General.ServerNames | `
                    ForEach {
                        return [pscustomobject]@{
                            "PSComputerName" = $_.PSComputerName
                            "DateTime" = $_.ConvertToDateTime($_.LocalDateTime)
                            "LastBootUptime" = $_.ConvertToDateTime($_.LastBootUptime) 
                        }
                    } | Sort "DateTime" -Descending
    
    # this is a poor measure - it ignores timezones - but it's good enough for what I need now...
    $difference = [timespan]::new(0)
    
    if ($results.Count -gt 1)
    {
        for ($i=0;$i -lt $results.count - 1;$i++)
            { $difference += $results[$i].DateTime.Subtract($results[$i + 1].DateTime) }
    } else { # if it's just a single server being tested, compare it against the local machine that PoShMon is running on
        $difference += (Get-Date).Subtract($results[0].DateTime)
    } 

    foreach ($serverResult in $results)
    {
        Write-Verbose ("`t" + $serverResult.PSComputerName + ": " + $serverResult.DateTime.ToShortTimeString())

        $highlight = @()
        
        if ($difference.Minutes -ge $PoShMonConfiguration.OperatingSystem.AllowedMinutesVarianceBetweenServerTimes)
        {
            $mainOutput.NoIssuesFound = $false
            $highlight += "CurrentTime"
            Write-Warning "`tDifference ($($difference.Minutes)) is above variance threshold minutes ($($PoShMonConfiguration.OperatingSystem.AllowedMinutesVarianceBetweenServerTimes))"
        }

        $startDateTime = (Get-Date).AddMinutes(-$PoShMonConfiguration.General.MinutesToScanHistory)
        if ($serverResult.LastBootUptime -ge $startDateTime)
        {
            $mainOutput.NoIssuesFound = $false
            $highlight += "LastBootUptime"
            Write-Warning "`tLastBootUptime ($($serverResult.LastBootUptime)) is within the last $($PoShMonConfiguration.General.MinutesToScanHistory) minutes"
        }

        $mainOutput.OutputValues += [pscustomobject]@{
            'ServerName' = $serverResult.PSComputerName
            'CurrentTime' = $serverResult.DateTime.ToString()
            'LastBootUptime' = $serverResult.LastBootUptime.ToString()
            'Highlight' = $highlight
        }
    }

    return (Complete-TimedOutput $mainOutput)
}