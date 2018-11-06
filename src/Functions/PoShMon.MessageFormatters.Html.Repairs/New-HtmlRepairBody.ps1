Function New-HtmlRepairBody
{
    [CmdletBinding()]
    Param(
        [hashtable]$PoShMonConfiguration,
        [object[]]$RepairOutputValues
    )

    $emailBody = ''
            
    $emailBody += New-HtmlHeader $PoShMonConfiguration "PoShMon Repairs Report"

    foreach ($repairOutputValue in $RepairOutputValues)
    {
        $emailBody += New-HtmlRepairOutputBody -Output $repairOutputValue
    }

    $emailBody += New-HtmlFooter $PoShMonConfiguration

    return $emailBody
}