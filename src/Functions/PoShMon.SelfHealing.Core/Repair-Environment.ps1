Function Repair-Environment
{
    [CmdletBinding()]
    Param(
        [hashtable]$poShMonConfiguration,
        [object[]]$PoShMonOutputValues,
        [string[]]$RepairScripts
    )

    $commands = Add-Scripts $RepairScripts

    try {
        $repairOutput = Invoke-Repairs $commands $PoShMonConfiguration $PoShMonOutputValues
    } catch {
        Send-ExceptionNotifications -PoShMonConfiguration $PoShMonConfiguration -Exception $_.Exception -Action "Repairing"
    }

    Initialize-RepairNotifications -PoShMonConfiguration $PoShMonConfiguration -RepairOutputValues $repairOutput
}