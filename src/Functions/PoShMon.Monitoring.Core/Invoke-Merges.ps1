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
    }
    
    End
    {
        return $TestOutputValues
    }
}