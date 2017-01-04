Function OperatingSystem
{
    [CmdletBinding()]
    param(
        [string[]]$EventLogCodes = 'Critical',
        [hashtable]$EventIDIgnoreList = @{},
        [double]$DriveSpaceThreshold = 10, #This is GB
        [double]$FreeMemoryThresholdPercent = 10,
        [string[]]$SpecialWindowsServices = $null
    )

    if ($Script:PoShMon.ConfigurationItems.OperatingSystem -eq $null)
        { $Script:PoShMon.ConfigurationItems.OperatingSystem = @{} }
    else {
        throw "OperatingSystem configuration group already created."
    }

    return @{
            TypeName = "PoShMon.ConfigurationItems.OperatingSystem"
            EventLogCodes = $EventLogCodes
            EventIDIgnoreList = $EventIDIgnoreList
            DriveSpaceThreshold = $DriveSpaceThreshold
            FreeMemoryThresholdPercent = $FreeMemoryThresholdPercent
            SpecialWindowsServices = $SpecialWindowsServices
        }
}