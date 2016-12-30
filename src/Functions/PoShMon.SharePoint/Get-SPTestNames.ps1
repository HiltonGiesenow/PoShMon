Function Get-SPTestNames
{
    [CmdletBinding()]
    Param(
    )

    $tests = @(
        "EventLogs",
        "DriveSpace",
        "SPServerStatus",
        "WindowsServiceState",
        "SPFailingTimerJobs",
        "SPDatabaseHealth",
        "SPSearchHealth",
        "SPDistributedCacheHealth",
        "WebTests"
    ) #storing them as an array in case it's useful...

    return "'" + [system.String]::Join("','", $tests) + "'" #formatted easily for use in TestsToSkip
}