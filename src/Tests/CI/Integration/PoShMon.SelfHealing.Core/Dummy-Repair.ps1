Function Global:Dummy-Repair
{
    [CmdletBinding()]
    Param(
        [hashtable]$PoShMonConfiguration,
        [System.Collections.ArrayList]$PoShMonOutputValues
    )

    return @{
        "SectionHeader" = "Mock Repair"
        "RepairResult" = "Some repair message"
    }    
}