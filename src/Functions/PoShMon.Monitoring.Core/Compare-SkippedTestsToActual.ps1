Function Compare-SkippedTestsToActual
{
    [CmdletBinding()]
    Param(
        [hashtable]$PoShMonConfiguration,
        [string[]]$TestList
    )

    foreach ($skippedTest in $poShMonConfiguration.General.TestsToSkip)
    {
        if (!$TestList.Contains($skippedTest))
            { Write-Warning "$skippedTest is specified to be skipped, but no such test exists" }
    }
}