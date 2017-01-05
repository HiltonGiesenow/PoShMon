Function Test-CPULoad
{
    [CmdletBinding()]
    param (
        [hashtable]$PoShMonConfiguration
    )

    if ($PoShMonConfiguration.OperatingSystem -eq $null) { throw "'OperatingSystem' configuration not set properly on PoShMonConfiguration parameter." }

    $stopWatch = [System.Diagnostics.Stopwatch]::StartNew()

    $sectionHeader = "Server CPU Load Review"
    $NoIssuesFound = $true
    $outputHeaders = [ordered]@{ 'ServerName' = 'Server Name'; 'CPULoad' = 'CPU Load (%)' }
    $outputValues = @()

    Write-Verbose "Performing $sectionHeader..."

    $results = Get-Counter "\processor(_total)\% processor time" -Computername $PoShMonConfiguration.General.ServerNames

    foreach ($counterResult in $results.CounterSamples)
    {
        $serverName = $counterResult.Path.Substring(2, $counterResult.Path.LastIndexOf("\\") - 2).ToUpper()
        $cpuLoad = $counterResult.CookedValue
        $highlight = @()

        Write-Verbose "` $serverName : $cpuLoad"

        if ($cpuLoad -gt $PoShMonConfiguration.OperatingSystem.CPULoadThresholdPercent)
        {
            $NoIssuesFound = $false
            $highlight += "CPULoad"
        }

        $outputValues += @{
            'ServerName' = $serverName
            'CPULoad' = ($cpuLoad / 100).ToString("00%")
            'Highlight' = $highlight
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