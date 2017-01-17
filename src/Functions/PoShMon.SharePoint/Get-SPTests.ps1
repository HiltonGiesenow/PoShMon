Function Get-SPTests
{
    [CmdletBinding()]
    Param(
    )

    $tests = @(
        #"FarmHealth",
        "EventLogs",
        "CPULoad",
        "Memory",
        "DriveSpace",
        "SPServerStatus",
        "SPWindowsServiceState",
        "SPJobHealth",
        "SPDatabaseHealth",
        "SPDistributedCacheHealth",
        "SPSearchHealth",
        "SPUPSSyncHealth",
        "WebSites"
    )

    return $tests
}