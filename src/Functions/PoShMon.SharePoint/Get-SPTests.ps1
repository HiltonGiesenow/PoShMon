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
        "ComputerTime",        
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