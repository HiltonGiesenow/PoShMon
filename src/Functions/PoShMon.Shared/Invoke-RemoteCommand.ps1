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
        $remoteSession = Connect-PSSession -ComputerName $PoShMonConfiguration.General.PrimaryServerName -Name $PoShMonConfiguration.General.RemoteSessionName -ConfigurationName $PoShMonConfiguration.General.ConfigurationName

        return Invoke-Command -Session $RemoteSession -ScriptBlock $scriptBlock -ArgumentList $ArgumentList

    } catch {
        throw $_.Exception
    } finally {
        if ($remoteSession -ne $null)
            { Disconnect-PSSession $remoteSession -ErrorAction SilentlyContinue }
            #{ Disconnect-RemoteSession $remoteSession -ErrorAction SilentlyContinue }
    }
}