Function Get-OSTestNames
{
    [CmdletBinding()]
    Param(
    )

    $tests = Get-OSTests

    return "'" + [system.String]::Join("','", $tests) + "'" #formatted easily for use in TestsToSkip
}