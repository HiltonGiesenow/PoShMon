Function Get-OOSTests
{
    [CmdletBinding()]
    Param(
    )

    $tests = [string[]]@(
        "EventLogs",
        "CPULoad",
        "Memory",
        "DriveSpace",
        "ComputerTime",
        "OOSWindowsServiceState"
        "WebSites"
    )

    return $tests
}