Function Get-OOSTestNames
{
    [CmdletBinding()]
    Param(
    )

    $tests = Get-OOSTests

    return "'" + [system.String]::Join("','", $tests) + "'" #formatted easily for use in TestsToSkip
}