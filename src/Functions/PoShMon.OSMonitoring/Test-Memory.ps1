Function Test-Memory
{
    [CmdletBinding()]
    param (
        [hashtable]$PoShMonConfiguration
    )

    if ($PoShMonConfiguration.OperatingSystem -eq $null) { throw "'OperatingSystem' configuration not set properly on PoShMonConfiguration parameter." }

    $mainOutput = Get-InitialOutputWithTimer -SectionHeader "Memory Review" -OutputHeaders ([ordered]@{ 'ServerName' = 'Server Name'; 'TotalMemory' = 'Total Memory (GB)'; 'FreeMemory' = 'Free Memory (GB)'; 'FreeMemoryPerc' = 'Free Memory (%)' })

    $results = Get-WmiObject Win32_OperatingSystem -Computername $PoShMonConfiguration.General.ServerNames

    foreach ($serverResult in $results)
    {
        Write-Verbose $serverResult.PSComputerName

        $freeMemoryPercent = $serverResult.FreePhysicalMemory / $serverResult.TotalVisibleMemorySize * 100
        $highlight = @()

        if ($freeMemoryPercent -lt $PoShMonConfiguration.OperatingSystem.FreeMemoryThresholdPercent)
        {
            $mainOutput.NoIssuesFound = $false
            $highlight += "FreeMemory"
        }

        $totalSpace = $serverResult.TotalVisibleMemorySize/1MB
        $freeSpace = $serverResult.FreePhysicalMemory/1MB

        Write-Verbose ("`t" + $totalSpace.ToString(".00") + " : " + $freeSpace.ToString(".00"))

        $mainOutput.OutputValues += @{
            'ServerName' = $serverResult.PSComputerName
            'TotalMemory' = $totalSpace.ToString(".00");
            'FreeMemory' = $freeSpace.ToString(".00");
            'FreeMemoryPerc' = $freeMemoryPercent.ToString("0") + "%";
            'Highlight' = $highlight
        }
    }

    return (Complete-TimedOutput $mainOutput)
}