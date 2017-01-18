Function Get-OSTests
{
    [CmdletBinding()]
    Param(
    )

    $tests = [string[]]@(
        "EventLogs",
        "CPULoad",
        "FreeMemory",
        "DriveSpace"
    )

    return $tests
}