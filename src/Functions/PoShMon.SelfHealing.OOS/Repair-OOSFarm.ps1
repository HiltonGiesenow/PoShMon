Function Repair-OOSFarm
{
    [CmdletBinding()]
    Param(
        [hashtable]$PoShMonConfiguration,
        [System.Collections.ArrayList]$PoShMonOutputValues
    )

    $repairFunctionNames = 'Repair-W3ServiceOnOOSHost'

    #try {
        $repairOutput = Invoke-Repairs $repairFunctionNames $PoShMonConfiguration $PoShMonOutputValues
    #} catch {
    #    Send-ExceptionNotifications -PoShMonConfiguration $PoShMonConfiguration -Exception $_.Exception -Action "Repairing"
    #}

    #Initialize-RepairNotifications -PoShMonConfiguration $PoShMonConfiguration -RepairOutputValues $repairOutput

    return $repairOutput
}