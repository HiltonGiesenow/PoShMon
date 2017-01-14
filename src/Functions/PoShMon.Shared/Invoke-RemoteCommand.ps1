Function Invoke-RemoteCommand
{
    [CmdletBinding()]
    Param(
        [hashtable]$PoShMonConfiguration,
        [scriptblock]$scriptBlock,
        [object[]]$ArgumentList = $null
    )

    try
    {
        $remoteSession = Connect-PSSession -Name "PoShMonSession"

        return Invoke-Command -Session $RemoteSession -ScriptBlock $scriptBlock -ArgumentList $ArgumentList

    } catch {
        throw $_.Exception
    } finally {
        if ($remoteSession -ne $null)
            { Disconnect-RemoteSession $remoteSession -ErrorAction SilentlyContinue }
    }
}