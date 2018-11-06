Function Repair-W3ServiceOnOOSHost
{
    [CmdletBinding()]
    Param(
        [hashtable]$PoShMonConfiguration,
        [System.Collections.ArrayList]$PoShMonOutputValues
    )

    $repairOutput = @()

    if ($Global:Error -ne $null -and $Global:Error.Count -gt 0)
    {
        $errorText = $Global:Error[0].Exception.ToString()

        if ($errorText.Contains("There was no endpoint listening at") -and $errorText.Contains("farmstatemanager/FarmStateManager.svc that could accept the message"))
        {
            $repairOutput = Start-ServicesOnServers $PoShMonConfiguration.General.PrimaryServerName "W3SVC"
        }
    }

    return $repairOutput
}