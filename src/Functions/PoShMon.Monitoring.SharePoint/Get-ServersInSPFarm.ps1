Function Get-ServersInSPFarm
{
    [CmdletBinding()]
    Param(
        [hashtable]$PoShMonConfiguration
    )            
    
    #try
    #{
        $remoteSession = Connect-RemoteSharePointSession $PoShMonConfiguration
    
        # Auto-Discover Servers
        $serverNames = Invoke-Command -Session $remoteSession -ScriptBlock {
                                                        Get-SPServer | Where Role -ne "Invalid" | Select -ExpandProperty Name }

        return $serverNames

    #} catch {
    #    throw $_.Exception
    #} finally {
    #    if ($remoteSession -ne $null)
    #        { Disconnect-PSSession $remoteSession -ErrorAction SilentlyContinue | Out-Null }
    #}
}