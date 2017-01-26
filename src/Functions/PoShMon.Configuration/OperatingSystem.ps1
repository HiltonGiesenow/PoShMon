Function OperatingSystem
{
    [CmdletBinding()]
    param(
        [string[]]$EventLogCodes = 'Critical',
        [hashtable]$EventIDIgnoreList = @{},
        [double]$CPULoadThresholdPercent = 90,
        [double]$FreeMemoryThresholdPercent = 10,
        [Parameter(ParameterSetName="DriveSpaceFixed")]
        [double]$DriveSpaceThreshold, #This is GB
        [Parameter(ParameterSetName="DriveSpacePercent")]
        [double]$DriveSpaceThresholdPercent, #This is GB
        [string[]]$WindowsServices = $null,
        [int]$AllowedMinutesVarianceBetweenServerTimes = 1
    )

    if ($Script:PoShMon.ConfigurationItems.OperatingSystem -eq $null)
        { $Script:PoShMon.ConfigurationItems.OperatingSystem = @{} }
    else {
        throw "OperatingSystem configuration group already created."
    }

    if ($DriveSpaceThresholdPercent -gt 99) { throw "DriveSpaceThresholdPercent too high" }    
    if ($DriveSpaceThresholdPercent -lt 1)  {throw "DriveSpaceThresholdPercent too low" }    
    if ($DriveSpaceThreshold -lt 1)  {throw "DriveSpaceThreshold too low" }    

    if ($DriveSpaceThreshold -eq 0 -and $DriveSpaceThresholdPercent -eq 0)
        { $DriveSpaceThreshold = 10 } #GB

    return @{
            TypeName = "PoShMon.ConfigurationItems.OperatingSystem"
            EventLogCodes = $EventLogCodes
            EventIDIgnoreList = $EventIDIgnoreList
            CPULoadThresholdPercent = $CPULoadThresholdPercent
            FreeMemoryThresholdPercent = $FreeMemoryThresholdPercent
            DriveSpaceThreshold = $DriveSpaceThreshold
            DriveSpaceThresholdPercent = $DriveSpaceThresholdPercent
            WindowsServices = $WindowsServices
            AllowedMinutesVarianceBetweenServerTimes = $AllowedMinutesVarianceBetweenServerTimes
        }
}