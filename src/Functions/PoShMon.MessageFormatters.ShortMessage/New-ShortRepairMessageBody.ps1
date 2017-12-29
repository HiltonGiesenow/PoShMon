Function New-ShortRepairMessageBody
{
    [CmdletBinding()]
    Param(
        [hashtable]$PoShMonConfiguration,
        [object[]]$RepairOutputValues
    )

    $messageBody = ''

    foreach ($repairOutputValue in $RepairOutputValues)
    {
        $messageBody += "$($repairOutputValue.SectionHeader) : "
        if ($repairOutputValue.ContainsKey("Exception"))
            { $messageBody += "(Exception occurred)`r`n" }
        else
            { $messageBody += "Repair performed`r`n" } 
    }

    return $messageBody
}