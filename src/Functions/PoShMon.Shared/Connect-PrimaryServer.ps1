Function Connect-PrimaryServer
{
    [CmdletBinding()]
    Param(
        [hashtable]$PoShMonConfiguration,
        [scriptblock]$InitiationScriptBlock,
        [object[]]$ArgumentList = $null
    )

    $remoteSession = Connect-RemoteSession $PoShMonConfiguration

    if ($InitiationScriptBlock -ne $null -and $InitiationScriptBlock -ne "")
        { Invoke-Command -Session $remoteSession -ScriptBlock $InitiationScriptBlock -ArgumentList $ArgumentList }

    $Global:PoShMon_RemoteSession = $remoteSession

    return $remoteSession
}