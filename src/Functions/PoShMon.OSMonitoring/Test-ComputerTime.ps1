Function Test-ComputerTime
{
    [CmdletBinding()]
    param (
        [hashtable]$PoShMonConfiguration
    )

    if ($PoShMonConfiguration.OperatingSystem -eq $null) { throw "'OperatingSystem' configuration not set properly on PoShMonConfiguration parameter." }

    $mainOutput = Get-InitialOutputWithTimer -SectionHeader "Server Clock Review" -OutputHeaders ([ordered]@{ 'ServerName' = 'Server Name'; 'CurrentTime' = 'Current Time' })

    $results = Get-WmiObject win32_localtime -Computername $PoShMonConfiguration.General.ServerNames

    # this is rough, poor measure - it ONLY checks absolute minutes across the servers (and ignores time zones etc.) but it's good enough for what I need now...
    $minutes = [int[]]$Results.Minute
    if ($minutes.Count -eq 1) { $minutes += (Get-Date).Minute } # if it's just a single server being tested, compare it against the local machine that PoShMon is running on
    $minutesMeasure = $minutes | Measure-Object -Sum
    $difference = [Math]::Abs(($minutes[0] * $minutes.Count) - $minutesMeasure.Sum)

    foreach ($serverResult in $results)
    {
        $time = Get-Date -Year $serverResult.Year -Month $serverResult.Month -Day $serverResult.Day -Hour $serverResult.Hour -Minute $serverResult.Minute -Second $serverResult.Second
        Write-Verbose ($serverResult.PSComputerName + ": " + $time.ToShortTimeString())

        $highlight = @()
        
        if ($difference -ge $PoShMonConfiguration.OperatingSystem.AllowedMinutesVarianceBetweenServerTimes)
        {
            $mainOutput.NoIssuesFound = $false
            $highlight += "CurrentTime"
        }

        $mainOutput.OutputValues += @{
            'ServerName' = $serverResult.PSComputerName
            'CurrentTime' = $time.ToString()
            'Highlight' = $highlight
        }
    }

    return (Complete-TimedOutput $mainOutput)
}