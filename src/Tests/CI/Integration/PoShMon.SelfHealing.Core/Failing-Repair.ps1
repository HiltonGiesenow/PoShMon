Function Failing-Repair
{
    [CmdletBinding()]
    Param(
        [hashtable]$PoShMonConfiguration,
        [object[]]$PoShMonOutputValues
    )

    throw "Something" 
}