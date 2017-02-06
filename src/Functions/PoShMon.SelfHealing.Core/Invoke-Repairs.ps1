Function Invoke-Repairs
{
    [CmdletBinding()]
    Param(
        [string[]]$RepairsToRuns,
        [hashtable]$PoShMonConfiguration,
        [object[]]$PoShMonOutputValues
    )

    Begin
    {
        $outputValues = @()
    }

    Process
    {
        foreach ($repair in $RepairsToRuns)
        {
            try {
                $outputValues += & $repair $PoShMonConfiguration $PoShMonOutputValues
            } catch {
                $outputValues += @{
                    "SectionHeader" = $repair;
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