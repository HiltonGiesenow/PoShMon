Function Test-DriveSpace
{
    [CmdletBinding()]
    param (
        [hashtable]$PoShMonConfiguration
    )

    if ($PoShMonConfiguration.OperatingSystem -eq $null) { throw "'OperatingSystem' configuration not set properly on PoShMonConfiguration parameter." }

    $stopWatch = [System.Diagnostics.Stopwatch]::StartNew()

    $mainOutput = Get-InitialOutput -SectionHeader "Harddrive Space Review" -OutputHeaders ([ordered]@{ 'DriveLetter' = 'Drive Letter'; 'TotalSpace' = 'Total Space (GB)'; 'FreeSpace' = 'Free Space (GB)' })

    foreach ($serverName in $PoShMonConfiguration.General.ServerNames)
    {
        Write-Verbose $serverName

        $itemOutputValues = @()
    
        $serverDriveSpace = Get-WmiObject win32_logicaldisk -Computername $serverName #this could be optimised to go to all servers at the same time..

        foreach ($drive in ($serverDriveSpace | Where DriveType -eq 3))
        {
            $totalSpace = $drive.Size/1GB
            $freeSpace = $drive.FreeSpace/1GB
            $highlight = @()

            if ($freeSpace -lt $PoShMonConfiguration.OperatingSystem.DriveSpaceThreshold)
            {
                $mainOutput.NoIssuesFound = $false
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

        $mainOutput.OutputValues += @{
                    'GroupName' = $serverName
                    'GroupOutputValues' = $itemOutputValues
                }
    }

    $stopWatch.Stop()

    $mainOutput.ElapsedTime = $stopWatch.Elapsed

    return $mainOutput
}