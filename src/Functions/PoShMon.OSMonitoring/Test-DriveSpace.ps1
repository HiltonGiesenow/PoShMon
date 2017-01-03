Function Test-DriveSpace
{
    [CmdletBinding()]
    param (
        [hashtable]$PoShMonConfiguration
    )

    if ($PoShMonConfiguration.OperatingSystem -eq $null) { throw "'OperatingSystem' configuration not set properly on PoShMonConfiguration parameter." }

    $stopWatch = [System.Diagnostics.Stopwatch]::StartNew()

    $sectionHeader = "Harddrive Space Review"
    $NoIssuesFound = $true
    $outputHeaders = @{ 'DriveLetter' = 'Drive Letter'; 'TotalSpace' = 'Total Space (GB)'; 'FreeSpace' = 'Free Space (GB)' }
    $outputValues = @()

    Write-Verbose "Getting Server Drive Space..."

    foreach ($serverName in $PoShMonConfiguration.General.ServerNames)
    {
        Write-Verbose $serverName

        $itemOutputValues = @()
    
        $serverDriveSpace = Get-WmiObject win32_logicaldisk -Computername $serverName

        foreach ($drive in ($serverDriveSpace | Where DriveType -eq 3))
        {
            $totalSpace = $drive.Size/1GB
            $freeSpace = $drive.FreeSpace/1GB
            $highlight = @()

            if ($freeSpace -lt $PoShMonConfiguration.OperatingSystem.DriveSpaceThreshold)
            {
                $NoIssuesFound = $false
                $highlight += "FreeSpace"
            }

            Write-Verbose ("`t" + $drive.DeviceID + " : " + $totalSpace.ToString(".00") + " : " + $freeSpace.ToString(".00"))

            $outputItem = @{
                'DriveLetter' = $drive.DeviceID;
                'TotalSpace' = $totalSpace.ToString(".00");
                'FreeSpace' = $freeSpace.ToString(".00");
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