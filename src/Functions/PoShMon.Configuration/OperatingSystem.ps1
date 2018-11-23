Function New-OSConfig
{
    [CmdletBinding(DefaultParameterSetName="All")]
    param(
        [string[]]$EventLogCodes = 'Critical',
        [hashtable]$EventIDIgnoreList = @{},
        [double]$CPULoadThresholdPercent = 90,
        [double]$FreeMemoryThresholdPercent = 10,
        [Parameter(ParameterSetName="DriveSpaceFixed")]
        [double]$DriveSpaceThreshold, #This is GB
        [Parameter(ParameterSetName="DriveSpacePercent")]
        [double]$DriveSpaceThresholdPercent, #This is GB
        [string[]]$WindowsServices = @(),
        [string[]]$WindowsServicesToSkip = @(),        
        [int]$AllowedMinutesVarianceBetweenServerTimes = 1,
        [scriptblock]$EventLogIgnores
    )

    if ($Script:PoShMon.ConfigurationItems.OperatingSystem -eq $null)
        { $Script:PoShMon.ConfigurationItems.OperatingSystem = @{} }
    else {
        throw "OperatingSystem configuration group already created."
    }

    if ($DriveSpaceThresholdPercent -gt 99) { throw "DriveSpaceThresholdPercent too high" }    
    if ($DriveSpaceThresholdPercent -lt 1 -and $DriveSpaceThreshold -lt 0)  {throw "DriveSpaceThresholdPercent too low" }    
    if ($DriveSpaceThreshold -lt 0)  {throw "DriveSpaceThreshold cannot be below zero" }     

    if ($DriveSpaceThreshold -eq 0 -and $DriveSpaceThresholdPercent -eq 0)
        { $DriveSpaceThreshold = 10 } #GB

    if ($EventIDIgnoreList.Count -gt 0)
    {
        Write-Warning "The 'EventIDIgnoreList' setting has been deprecated, please use 'EventLogIgnore' instances, for example New-PoShMonConfiguration { OperatingSystem { EventLogIgnore 123, EventLogIgnore 456 }}"
        foreach ($EventIDIgnoreListKey in $EventIDIgnoreList.Keys) {
            $eventLogIgnoresActual += New-EventLogIgnore $EventIDIgnoreListKey
        }
    } else {
        if ($EventLogIgnores -ne $null)
            { $eventLogIgnoresActual = . $EventLogIgnores }
    }

    return @{
            TypeName = "PoShMon.ConfigurationItems.OperatingSystem"
            EventLogCodes = $EventLogCodes
            #EventIDIgnoreList = $EventIDIgnoreList
            CPULoadThresholdPercent = $CPULoadThresholdPercent
            FreeMemoryThresholdPercent = $FreeMemoryThresholdPercent
            DriveSpaceThreshold = $DriveSpaceThreshold
            DriveSpaceThresholdPercent = $DriveSpaceThresholdPercent
            WindowsServices = $WindowsServices
            WindowsServicesToSkip = $WindowsServicesToSkip
            AllowedMinutesVarianceBetweenServerTimes = $AllowedMinutesVarianceBetweenServerTimes
            EventLogIgnores = $eventLogIgnoresActual
        }
}