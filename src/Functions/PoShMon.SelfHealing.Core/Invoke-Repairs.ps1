Function Invoke-Repairs
{
    [CmdletBinding()]
    Param(
        [string[]]$RepairFunctionNames,
        [hashtable]$PoShMonConfiguration,
        [System.Collections.ArrayList]$PoShMonOutputValues
    )

    Begin
    {
        $outputValues = @()
    }

    Process
    {
        foreach ($repairFunctionName in $RepairFunctionNames)
        {

            try {
                $outputValues += & $repairFunctionName $PoShMonConfiguration $PoShMonOutputValues
            } catch {
                $outputValues += @{
                    "SectionHeader" = $repairFunctionName;
                    "Exception" = $_.Exception
                }
            }

        }
    }
    
    End
    {
        if ($outputValues.Count -eq 0)
            { Write-Verbose "No valid repairs found to perform" }

        Initialize-RepairNotifications -PoShMonConfiguration $PoShMonConfiguration -RepairOutputValues $outputValues

        return $outputValues
    }
}