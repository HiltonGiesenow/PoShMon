Function Get-FinalTestsToRun
{
    [CmdletBinding()]
    Param(
        [string[]]$AllTests,
        [hashtable]$PoShMonConfiguration
    )

    $tests = New-Object System.Collections.ArrayList
    $tests.AddRange($AllTests)

    $PoShMonConfiguration.General.TestsToSkip | foreach { $tests.Remove($_) }

    return $tests
}