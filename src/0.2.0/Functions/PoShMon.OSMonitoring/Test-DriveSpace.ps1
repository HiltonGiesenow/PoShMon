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