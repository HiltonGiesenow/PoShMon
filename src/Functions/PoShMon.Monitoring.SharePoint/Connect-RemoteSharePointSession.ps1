Function Connect-RemoteSharePointSession
{
    [cmdletbinding()]
    param(
        #[parameter(Mandatory=$true)][string]$ServerName,
        #[string]$ConfigurationName = $null
        [hashtable]$PoShMonConfiguration
    )

    $remoteSession = Connect-RemoteSession @PSBoundParameters

    Invoke-Command -Session $remoteSession -ScriptBlock {
        Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
    }

    $Global:PoShMon_RemoteSession = $remoteSession

    return $remoteSession
}