Function Get-SPTestNames
{
    [CmdletBinding()]
    Param(
    )

    $tests = Get-SPTests

    return "'" + [system.String]::Join("','", $tests) + "'" #formatted easily for use in TestsToSkip
}