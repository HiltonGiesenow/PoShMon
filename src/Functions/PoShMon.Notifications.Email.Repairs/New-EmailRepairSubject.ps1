Function New-EmailRepairSubject
{
    [CmdletBinding()]
    param(
        [hashtable]$PoShMonConfiguration,
        [System.Collections.ArrayList]$RepairOutputValues
    )

    $subject = "[PoshMon] $($PoShMonConfiguration.General.EnvironmentName) Repair Results ($($RepairOutputValues.Count) Repairs(s) Performed)"

    return $subject
}