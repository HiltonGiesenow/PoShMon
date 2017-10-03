Function Optimize-Output
{
    [CmdletBinding()]
    param (
        [hashtable]$PoShMonConfiguration,
        [System.Collections.ArrayList]$TestOutputValues,
        [string[]]$OutputOptimizationList
    )

    Write-Verbose "Optimizing Output..."

    foreach ($optimizationFunction in $OutputOptimizationList)
    {
        $TestOutputValues = & ("Resolve-" + $optimizationFunction) $PoShMonConfiguration $TestOutputValues
    }

    # now include any extra supplied resolvers, not part of the PoShMon project itself
    foreach ($extraResolverFile in $PoShMonConfiguration.Extensibility.ExtraResolverFilesToInclude)
    {
        if (Test-Path $extraResolverFile)
        {
            . $extraResolverFile # Load the script

            $resolverName = $extraResolverFile | Get-Item | Select -ExpandProperty BaseName

            #$TestOutputValues = & $resolverName $PoShMonConfiguration $TestOutputValues
            & $resolverName $PoShMonConfiguration $TestOutputValues

        } else {
            Write-Warning "Resolver file not found, will be skipped: $extraResolverFile"
        }
    }
    
    #return $TestOutputValues
}