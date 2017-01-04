Function Test-Memory
{
    [CmdletBinding()]
    param (
        [hashtable]$PoShMonConfiguration
    )

    if ($PoShMonConfiguration.OperatingSystem -eq $null) { throw "'OperatingSystem' configuration not set properly on PoShMonConfiguration parameter." }

    $stopWatch = [System.Diagnostics.Stopwatch]::StartNew()

    $sectionHeader = "Memory Review"
    $NoIssuesFound = $true
    $outputHeaders = [ordered]@{ 'ServerName' = 'Server Name'; 'TotalMemory' = 'Total Memory (GB)'; 'FreeMemory' = 'Free Memory (GB)'; 'FreeSpacePerc' = 'Free Space (%)' }
    $outputValues = @()

    Write-Verbose "Getting Memory..."

    $results = Get-WmiObject Win32_OperatingSystem -Computername $PoShMonConfiguration.General.ServerNames

    foreach ($serverResult in $results)
    {
        Write-Verbose $serverResult.PSComputerName

        $freeMemoryPercent = $serverResult.FreePhysicalMemory / $serverResult.TotalVisibleMemorySize * 100

        if ($freeMemoryPercent -lt $PoShMonConfiguration.OperatingSystem.FreeMemoryThresholdPercent)
        {
            $NoIssuesFound = $false
            $highlight += "FreeMemory"
        }

        $totalSpace = $serverResult.TotalVisibleMemorySize/1MB
        $freeSpace = $serverResult.FreePhysicalMemory/1MB

        Write-Verbose ("`t" + $totalSpace.ToString(".00") + " : " + $freeSpace.ToString(".00"))

        $outputValues += @{
            'ServerName' = $serverResult.PSComputerName
            'TotalMemory' = $totalSpace.ToString(".00");
            'FreeMemory' = $freeSpace.ToString(".00");
            'FreeSpacePerc' = $freeMemoryPercent.ToString("0") + "%";
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