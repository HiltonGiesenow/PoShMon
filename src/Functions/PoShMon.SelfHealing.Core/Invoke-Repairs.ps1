Function Invoke-Repairs
{
    [CmdletBinding()]
    Param(
        [string[]]$RepairScripts,
        [hashtable]$PoShMonConfiguration,
        [System.Collections.ArrayList]$PoShMonOutputValues
    )

    Begin
    {
        $outputValues = @()
    }

    Process
    {
        foreach ($repairScript in $RepairScripts)
        {
            if (Test-Path $repairScript)
            {
                . $repairScript # Load the script

                $repairFunctionName = $repairScript | Get-Item | Select -ExpandProperty BaseName

                try {
                    $outputValues += & $repairFunctionName $PoShMonConfiguration $PoShMonOutputValues
                } catch {
                    $outputValues += @{
                        "SectionHeader" = $repairFunctionName;
                        "Exception" = $_.Exception
                    }
                }

            } else {
                Write-Warning "Script not found, will be skipped: $scriptToImport"
            }
        }
    }
    
    End
    {
        return $outputValues
    }
}