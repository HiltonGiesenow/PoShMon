Function Optimize-Output
{
    [CmdletBinding()]
    param (
        [hashtable]$PoShMonConfiguration,
        [object[]]$TestOutputValues,
        [string[]]$OutputOptimizationList
    )

    Write-Verbose "Optimizing Output..."

    foreach ($optimizationFunction in $OutputOptimizationList)
    {
        $TestOutputValues = & ("Resolve-" + $optimizationFunction) $PoShMonConfiguration $TestOutputValues
    }

    return $TestOutputValues
}