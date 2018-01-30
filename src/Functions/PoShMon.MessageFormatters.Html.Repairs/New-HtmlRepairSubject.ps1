Function New-HtmlRepairSubject
{
    [CmdletBinding()]
    param(
        [hashtable]$PoShMonConfiguration,
        [object[]]$RepairOutputValues
    )

    $subject = "[PoshMon] $($PoShMonConfiguration.General.EnvironmentName) Repair Results ($($RepairOutputValues.Count) Repairs(s) Performed)"

    return $subject
}