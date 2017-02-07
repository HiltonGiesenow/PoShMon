Function Get-OSTests
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
        "ServiceState"
    )

    return $tests
}