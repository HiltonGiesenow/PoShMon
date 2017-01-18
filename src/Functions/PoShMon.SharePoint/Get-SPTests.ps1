Function Get-SPTests
{
    [CmdletBinding()]
    Param(
    )

    $tests = [string[]]@(
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