Function Connect-RemoteSession
{
    [cmdletbinding()]
    param(
        [parameter(Mandatory=$true)][string]$ServerName,
        [string]$ConfigurationName = $null
    )

    if ($ConfigurationName -ne $null)
        { $remoteSession = New-PSSession -ComputerName $ServerName -ConfigurationName $ConfigurationName }
    else
        { $remoteSession = New-PSSession -ComputerName $ServerName }

    return $remoteSession
}