Function Invoke-Tests
{
    [CmdletBinding()]
    Param(
        [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [string[]]$TestToRuns,
        [hashtable]$PoShMonConfiguration
    )

    Begin
    {
        $outputValues = @()
    }

    Process
    {
        foreach ($test in $TestToRuns)
        {
            $outputValues += & ("Test-" + $test) $PoShMonConfiguration
        }
    }
    
    End
    {
        return $outputValues
    }
}