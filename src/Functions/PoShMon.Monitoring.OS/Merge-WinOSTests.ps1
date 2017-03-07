Function Merge-WinOSTests
{
    [CmdletBinding()]
    param (
        [hashtable]$PoShMonConfiguration,
        [object[]]$TestOutputValues
    )

    $mergableOutputValues = $TestOutputValues | Where SectionHeader -In "Server CPU Load Review", "Memory Review","Server Clock Review"

    if ($mergableOutputValues.Count -gt 1) #make sure there's enough to merge
    {
        $newOutput 
    }
}