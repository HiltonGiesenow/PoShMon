Function Get-OSTestNames
{
    [CmdletBinding()]
    Param(
    )

    $tests = @(
        "EventLogs",
        "Memory",
        "DriveSpace"
    ) #storing them as an array in case it's useful...

    return "'" + [system.String]::Join("','", $tests) + "'" #formatted easily for use in TestsToSkip
}