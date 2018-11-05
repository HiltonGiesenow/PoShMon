Function Get-ServersInSPFarm
{
    [CmdletBinding()]
    Param(
        [hashtable]$PoShMonConfiguration
    )            
    
    #try
    #{
        $remoteSession = Connect-PrimaryServer -PoShMonConfiguration $PoShMonConfiguration -InitiationScriptBlock {
                            Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
                        }

        # Auto-Discover Central Admin url
        if ($PoShMonConfiguration.SharePoint.CentralAdminUrl -eq $null -or $PoShMonConfiguration.SharePoint.CentralAdminUrl -eq '')
        {
            $PoShMonConfiguration.SharePoint.CentralAdminUrl = Invoke-Command -Session $remoteSession -ScriptBlock {
                                  $ca = Get-SPWebApplication -IncludeCentralAdministration | Where IsAdministrationWebApplication -eq $true
                                  return $ca.url.Substring(0, $ca.url.Length - 1)
                            }
        }

        # Auto-Discover Servers
        $serverNames = Invoke-Command -Session $remoteSession -ScriptBlock {
                                                        Get-SPServer | Where Role -ne "Invalid" | Select -ExpandProperty Name
                                                    } -ErrorAction Stop

        return $serverNames

    #} catch {
    #    throw $_.Exception
    #} finally {
    #    if ($remoteSession -ne $null)
    #        { Disconnect-PSSession $remoteSession -ErrorAction SilentlyContinue | Out-Null }
    #}
}