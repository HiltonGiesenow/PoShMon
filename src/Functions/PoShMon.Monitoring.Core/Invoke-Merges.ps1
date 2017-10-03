Function Invoke-Merges
{
    [CmdletBinding()]
    Param(
        [hashtable]$PoShMonConfiguration,
        [System.Collections.ArrayList]$TestOutputValues,
        [string[]]$MergesToRuns
    )

    Begin
    {
    }

    Process
    {
        foreach ($merge in $MergesToRuns)
        {
            #try {
                $TestOutputValues = & ("Merge-" + $merge) $PoShMonConfiguration $TestOutputValues
            #} catch {
            #}
        }

        # now include any extra supplied resolvers, not part of the PoShMon project itself
        foreach ($extraMergerFile in $PoShMonConfiguration.Extensibility.ExtraMergerFilesToInclude)
        {
            if (Test-Path $extraMergerFile)
            {
                . $extraMergerFile # Load the script

                $mergerName = $extraMergerFile | Get-Item | Select -ExpandProperty BaseName

                & $mergerName $PoShMonConfiguration $TestOutputValues
            } else {
                Write-Warning "Merger file not found, will be skipped: $extraMergerFile"
            }
        }
    }
    
    End
    {
        return $TestOutputValues
    }
}