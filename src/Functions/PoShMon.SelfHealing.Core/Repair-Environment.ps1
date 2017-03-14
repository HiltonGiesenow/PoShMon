Function Repair-Environment
{
    [CmdletBinding()]
    Param(
        [hashtable]$poShMonConfiguration,
        [System.Collections.ArrayList]$PoShMonOutputValues,
        [string[]]$RepairScripts
    )

    #$commands = Add-Scripts $RepairScripts

    try {
        $repairOutput = Invoke-Repairs $RepairScripts $PoShMonConfiguration $PoShMonOutputValues
    } catch {
        Send-ExceptionNotifications -PoShMonConfiguration $PoShMonConfiguration -Exception $_.Exception -Action "Repairing"
    }

    Initialize-RepairNotifications -PoShMonConfiguration $PoShMonConfiguration -RepairOutputValues $repairOutput
}