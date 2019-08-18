Function Get-OOSFarmVersion
{
    [CmdletBinding()]
    param (
        [hashtable]$PoShMonConfiguration
    )

    Write-Verbose "Checking Office Online Server farm version..."

    # A note on the check below: I'm not sure if it's best to use the ExternalURL from whatever server is running PoShMon, or to use InternalURL from the server itself - it might depend on the specific installation/implementation
    # See here for another option: https://blogs.technet.microsoft.com/sammykailini/2013/09/20/how-to-find-the-version-or-build-number-for-an-office-web-apps-2013-farm/

    $farmAddress = Invoke-RemoteCommand -PoShMonConfiguration $PoShMonConfiguration -ScriptBlock {
                            return (Get-OfficeWebAppsFarm).ExternalURL
                        }

    $response = Invoke-WebRequest $farmAddress
    $farmVersion = $response.Headers["X-OfficeVersion"]

    return $farmVersion
}