Function Invoke-Tests
{
    [CmdletBinding()]
    Param(
        #[Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [System.Collections.ArrayList]$TestsToRun,
        [hashtable]$PoShMonConfiguration
    )

    $outputValues = @()

    foreach ($test in $testsToRun)
    {
        $outputValues += & ("Test-" + $test) $PoShMonConfiguration
    }

    return $outputValues
}