Function Get-SPResolutions
{
    [CmdletBinding()]
    Param(
    )

    $tests = [string[]]@(
        "HighCPUWhileSearchRunning"
    )

    return $tests
}