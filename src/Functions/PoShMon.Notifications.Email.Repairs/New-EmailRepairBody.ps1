Function New-EmailRepairBody
{
    [CmdletBinding()]
    Param(
        [hashtable]$PoShMonConfiguration,
        [object[]]$RepairOutputValues
    )

    $emailBody = ''
            
    $emailBody += New-EmailRepairHeader "$($PoShMonConfiguration.General.EnvironmentName) Repairs Report"

    foreach ($repairOutputValue in $RepairOutputValues)
    {
        $emailBody += New-EmailRepairOutputBody -Output $repairOutputValue
    }

    $emailBody += New-EmailRepairFooter

    return $emailBody
}