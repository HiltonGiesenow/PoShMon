Function Complete-TimedOutput
{
    [CmdletBinding()]
    param(
        [Hashtable]$TestOutputValues
    )

    $TestOutputValues.StopWatch.Stop()

    $TestOutputValues.ElapsedTime = $TestOutputValues.StopWatch.Elapsed

    $TestOutputValues.Remove("StopWatch")

    $issuesFound = if ($TestOutputValues.NoIssuesFound) { "No" } else { "Yes" }

    Write-Verbose "Complete '$($TestOutputValues.SectionHeader)' Test, Issues Found: $issuesFound"

    return $TestOutputValues
}