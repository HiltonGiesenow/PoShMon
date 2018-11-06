Function Repair-Environment
{
    [CmdletBinding()]
    Param(
        [hashtable]$PoShMonConfiguration,
        [System.Collections.ArrayList]$PoShMonOutputValues,
        [string[]]$RepairScripts
    )

    $repairFunctionNames = Import-RepairScripts $RepairScripts

    #try {
        $repairOutput = Invoke-Repairs $repairFunctionNames $PoShMonConfiguration $PoShMonOutputValues
    #} catch {
    #    Send-ExceptionNotifications -PoShMonConfiguration $PoShMonConfiguration -Exception $_.Exception -Action "Repairing"
    #}

    return $repairOutput
}