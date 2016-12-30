Function Connect-RemoteSharePointSession
{
    [cmdletbinding()]
    param(
        [parameter(Mandatory=$true)][string]$ServerName,
        [string]$ConfigurationName = $null
    )

    $remoteSession = Connect-RemoteSession @PSBoundParameters

    Invoke-Command -Session $remoteSession -ScriptBlock {
        Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
        #Import-Module "X:\Admin Scripts\PoShMon_Dev\0.1.0\Modules\PoShMon.psd1" #TODO: need to improve this once PoShMon is packaged and, e.g. on PowerShellGallery
    }

    return $remoteSession
}