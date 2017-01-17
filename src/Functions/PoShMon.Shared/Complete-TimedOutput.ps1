Function Complete-TimedOutput
{
    [CmdletBinding()]
    param(
        [Hashtable]$TestOutputValues
    )

    $TestOutputValues.StopWatch.Stop()

    $TestOutputValues.ElapsedTime = $TestOutputValues.StopWatch.Elapsed

    $TestOutputValues.Remove("StopWatch")

    return $TestOutputValues
}