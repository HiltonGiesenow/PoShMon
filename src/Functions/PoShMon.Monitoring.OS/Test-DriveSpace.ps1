Function Test-DriveSpace
{
    [CmdletBinding()]
    param (
        [hashtable]$PoShMonConfiguration
    )

    if ($PoShMonConfiguration.OperatingSystem -eq $null) { throw "'OperatingSystem' configuration not set properly on PoShMonConfiguration parameter." }

    $mainOutput = Get-InitialOutputWithTimer -SectionHeader "Harddrive Space Review" -GroupBy 'ServerName' -OutputHeaders ([ordered]@{ 'DriveLetter' = 'Drive Letter'; 'DriveName' = 'Drive Name'; 'TotalSpace' = 'Total Space (GB)'; 'FreeSpace' = 'Free Space (GB) (%)' })

    foreach ($serverName in $PoShMonConfiguration.General.ServerNames)
    {
        Write-Verbose "`t$serverName"

        $itemOutputValues = @()
    
        $serverDriveSpace = Get-WmiObject win32_logicaldisk -Computername $serverName #this could be optimised to go to all servers at the same time..

        foreach ($drive in ($serverDriveSpace | Where DriveType -eq 3))
        {
            $totalSpace = $drive.Size/1GB
            $freeSpace = $drive.FreeSpace/1GB
            $freeSpacePercent = $freeSpace / $totalSpace * 100
            $highlight = @()

            Write-Verbose ("`t`t" + $drive.DeviceID + " : " + $totalSpace.ToString(".00") + " : " + $freeSpace.ToString(".00") + " (" + $freeSpacePercent.ToString("00") + "%)")

            if ($PoShMonConfiguration.OperatingSystem.DriveSpaceThresholdPercent -gt 0)
            {
                if ($freeSpacePercent -lt $PoShMonConfiguration.OperatingSystem.DriveSpaceThresholdPercent)
                {
                    $mainOutput.NoIssuesFound = $false
                    $highlight += "FreeSpace"
                    Write-Warning "`t`tFree drive Space ($("{0:N0}" -f $freeSpacePercent)%) is below variance threshold ($($PoShMonConfiguration.OperatingSystem.DriveSpaceThresholdPercent)%)"
                }
            }
            elseif ($freeSpace -lt $PoShMonConfiguration.OperatingSystem.DriveSpaceThreshold)
            {
                $mainOutput.NoIssuesFound = $false
                $highlight += "FreeSpace"
                Write-Warning "`t`tFree drive Space ($($freeSpace.ToString(".00"))) is below variance threshold ($($PoShMonConfiguration.OperatingSystem.DriveSpaceThreshold))"
            }

            # $outputItem = @{
            $mainOutput.OutputValues += [pscustomobject]@{
				'ServerName' = $serverName;
				'DriveName' = $drive.VolumeName;
                'DriveLetter' = $drive.DeviceID;
                'TotalSpace' = $totalSpace.ToString(".00");
                'FreeSpace' = $freeSpace.ToString(".00") + " (" + $freeSpacePercent.ToString("00") + "%)";
                'Highlight' = $highlight
            }

            $itemOutputValues += $outputItem
        }

        # $mainOutput.OutputValues += @{
        #             'GroupName' = $serverName
        #             'GroupOutputValues' = $itemOutputValues
        #         }
    }

    return (Complete-TimedOutput $mainOutput)
}