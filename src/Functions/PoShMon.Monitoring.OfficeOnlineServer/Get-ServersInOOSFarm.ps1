Function Get-ServersInOOSFarm
{
    [CmdletBinding()]
    Param(
        [hashtable]$PoShMonConfiguration
    )            
    
    #try
    #{
        $remoteSession = Connect-PrimaryServer -PoShMonConfiguration $PoShMonConfiguration
    
        # Auto-Discover Servers
        $serverNames = Invoke-Command -Session $remoteSession -ScriptBlock {
                            Get-OfficeWebAppsFarm | Select -ExpandProperty Machines | Select -ExpandProperty MachineName
                        } -ErrorAction Stop

        return $serverNames

    #} catch {
    #    throw $_.Exception
    #} finally {
    #    if ($remoteSession -ne $null)
    #        { Disconnect-PSSession $remoteSession -ErrorAction SilentlyContinue | Out-Null }
    #}
}