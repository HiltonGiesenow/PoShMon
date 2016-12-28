Function OperatingSystem
{
    [CmdletBinding()]
    param(
        [int]$MinutesToScanHistory = 15,
        [string[]]$EventLogCodes = 'Critical',
        [hashtable]$EventIDIgnoreList = @{},
        [string[]]$SpecialWindowsServices = $null
    )

    if ($Script:PoShMon.ConfigurationItems.OperatingSystem -eq $null)
        { $Script:PoShMon.ConfigurationItems.OperatingSystem = @{} }
    else {
        throw "OperatingSystem configuration group already created."
    }

    return @{
            TypeName = "PoShMon.ConfigurationItems.OperatingSystem"
            MinutesToScanHistory = $MinutesToScanHistory
            EventLogCodes = $EventLogCodes
            EventIDIgnoreList = $EventIDIgnoreList
            SpecialWindowsServices = $SpecialWindowsServices
        }
}