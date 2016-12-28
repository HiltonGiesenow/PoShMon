Function Disconnect-RemoteSession
{
    [cmdletbinding()]
    param(
        $RemoteSession
    )

    Remove-PSSession $RemoteSession
}