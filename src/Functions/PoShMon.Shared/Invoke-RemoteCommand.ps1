Function Invoke-RemoteCommand
{
    [CmdletBinding()]
    Param(
        [hashtable]$PoShMonConfiguration,
        [scriptblock]$scriptBlock,
        [object[]]$ArgumentList = $null
    )

    #try
    #{
        if ($Global:PoShMon_RemoteSession -eq $null)
            { throw "No Remote Session Defined" }

        #$remoteSession = Connect-PSSession -ComputerName $PoShMonConfiguration.General.PrimaryServerName -Name $PoShMonConfiguration.General.RemoteSessionName -ConfigurationName $PoShMonConfiguration.General.ConfigurationName

        #return Invoke-Command -Session $RemoteSession -ScriptBlock $scriptBlock -ArgumentList $ArgumentList
        return Invoke-Command -Session $Global:PoShMon_RemoteSession -ScriptBlock $scriptBlock -ArgumentList $ArgumentList
    #} catch {
    #    throw $_.Exception
    #} finally {
    #    if ($remoteSession -ne $null)
    #        { Disconnect-PSSession $remoteSession -ErrorAction SilentlyContinue | Out-Null }
    #        #{ Disconnect-RemoteSession $remoteSession -ErrorAction SilentlyContinue }
    #}
}