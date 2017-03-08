Function New-PushbulletRepairMessageBody
{
    [CmdletBinding()]
    Param(
        [hashtable]$PoShMonConfiguration,
        [System.Collections.ArrayList]$RepairOutputValues
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