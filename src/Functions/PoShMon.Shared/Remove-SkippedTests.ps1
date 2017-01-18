Function Remove-SkippedTests
{
    [CmdletBinding()]
    Param(
        [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [string[]]$AllTests,
        [hashtable]$PoShMonConfiguration
    )

    Begin
    {
        $tests = [string[]]@()
    }

    Process
    {
        foreach ($test in $AllTests)
        {
            if (!$poShMonConfiguration.General.TestsToSkip.Contains($test))
                { $tests += $test }
        }
    }

    End
    {
        return $tests
    }
}