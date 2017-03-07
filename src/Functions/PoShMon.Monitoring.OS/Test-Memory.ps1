Function Test-Memory
{
    [CmdletBinding()]
    param (
        [hashtable]$PoShMonConfiguration
    )

    if ($PoShMonConfiguration.OperatingSystem -eq $null) { throw "'OperatingSystem' configuration not set properly on PoShMonConfiguration parameter." }

    $mainOutput = Get-InitialOutputWithTimer -SectionHeader "Memory Review" -OutputHeaders ([ordered]@{ 'ServerName' = 'Server Name'; 'TotalMemory' = 'Total Memory (GB)'; 'FreeMemory' = 'Free Memory (GB) (%)' })

    $results = Get-WmiObject Win32_OperatingSystem -ComputerName $PoShMonConfiguration.General.ServerNames

    foreach ($serverResult in $results)
    {
        $freeMemoryPercent = $serverResult.FreePhysicalMemory / $serverResult.TotalVisibleMemorySize * 100
        $highlight = @()

        $totalSpace = $serverResult.TotalVisibleMemorySize/1MB
        $freeSpace = $serverResult.FreePhysicalMemory/1MB

        Write-Verbose ("`t" + $serverResult.PSComputerName + " : " + $totalSpace.ToString(".00") + " : " + $freeSpace.ToString(".00") + " (" + $freeMemoryPercent.ToString("00") + "%)")

        if ($freeMemoryPercent -lt $PoShMonConfiguration.OperatingSystem.FreeMemoryThresholdPercent)
        {
            $mainOutput.NoIssuesFound = $false
            $highlight += "FreeMemory"
            Write-Warning "`t`tFree memory ($($freeMemoryPercent.ToString("0") + "%")) is below variance threshold ($($PoShMonConfiguration.OperatingSystem.FreeMemoryThresholdPercent))"
        }

        $mainOutput.OutputValues += [pscustomobject]@{
            'ServerName' = $serverResult.PSComputerName
            'TotalMemory' = $totalSpace.ToString(".00");
            'FreeMemory' = $freeSpace.ToString(".00") + " (" + $freeMemoryPercent.ToString("00") + "%)";
            'Highlight' = $highlight
        }
    }

    return (Complete-TimedOutput $mainOutput)
}