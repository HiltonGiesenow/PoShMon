Function Get-SPTestNames
{
    [CmdletBinding()]
    Param(
    )

    $tests = @(
        "EventLogs",
        "CPULoad",
        "FreeMemory",
        "DriveSpace",
        "SPServerStatus",
        "WindowsServiceState",
        "SPFailingTimerJobs",
        "SPDatabaseHealth",
        "SPDistributedCacheHealth",
        "SPSearchHealth",
        "SPUPSSyncHealth",
        "WebTests"
    ) #storing them as an array in case it's useful...

    return "'" + [system.String]::Join("','", $tests) + "'" #formatted easily for use in TestsToSkip
}