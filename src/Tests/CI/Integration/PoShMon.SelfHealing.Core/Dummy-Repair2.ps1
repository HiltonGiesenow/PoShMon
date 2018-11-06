Function Global:Dummy-Repair2
{
    [CmdletBinding()]
    Param(
        [hashtable]$PoShMonConfiguration,
        [System.Collections.ArrayList]$PoShMonOutputValues
    )

    return @{
        "SectionHeader" = "Another Mock Repair"
        "RepairResult" = "Another repair message"
    }
}