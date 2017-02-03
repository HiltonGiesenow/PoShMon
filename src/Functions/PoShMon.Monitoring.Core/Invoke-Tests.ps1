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
            try {
                $outputValues += & ("Test-" + $test) $PoShMonConfiguration
            } catch {
                $outputValues += @{
                    "SectionHeader" = $test;
                    "NoIssuesFound" = $false;
                    "Exception" = $_.Exception
                }
            }
        }
    }
    
    End
    {
        return $outputValues
    }
}