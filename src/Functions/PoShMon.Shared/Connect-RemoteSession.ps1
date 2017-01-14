Function Connect-RemoteSession
{
    [cmdletbinding()]
    param(
        #[parameter(Mandatory=$true)][string]$ServerName,
        #[string]$ConfigurationName = $null
        [hashtable]$PoShMonConfiguration
    )

    if ($PoShMonConfiguration.General.ConfigurationName -ne $null)
        { $remoteSession = New-PSSession -ComputerName $PoShMonConfiguration.General.PrimaryServerName -Name $PoShMonConfiguration.General.RemoteSessionName -ConfigurationName $PoShMonConfiguration.General.ConfigurationName }
    else
        { $remoteSession = New-PSSession -ComputerName $PoShMonConfiguration.General.PrimaryServerName -Name $PoShMonConfiguration.General.RemoteSessionName }

    return $remoteSession
}