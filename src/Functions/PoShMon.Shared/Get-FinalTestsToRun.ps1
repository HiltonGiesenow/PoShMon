Function Get-FinalTestsToRun
{
    [CmdletBinding()]
    Param(
        #[Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [string[]]$AllTests,
        [hashtable]$PoShMonConfiguration
    )

    $tests = New-Object System.Collections.ArrayList
    $tests.AddRange($AllTests)

    $PoShMonConfiguration.General.TestsToSkip | foreach { $tests.Remove($_) }

    return $tests
}