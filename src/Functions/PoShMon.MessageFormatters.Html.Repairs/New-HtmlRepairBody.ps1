Function New-HtmlRepairBody
{
    [CmdletBinding()]
    Param(
        [hashtable]$PoShMonConfiguration,
        [object[]]$RepairOutputValues
    )

    $emailBody = ''
            
    $emailBody += New-HtmlRepairHeader "$($PoShMonConfiguration.General.EnvironmentName) Repairs Report"

    foreach ($repairOutputValue in $RepairOutputValues)
    {
        $emailBody += New-HtmlRepairOutputBody -Output $repairOutputValue
    }

    $emailBody += New-HtmlRepairFooter

    return $emailBody
}