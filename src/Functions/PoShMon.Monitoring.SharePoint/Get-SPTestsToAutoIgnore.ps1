Function Get-SPTestsToAutoIgnore
{
    [CmdletBinding()]
    param (
        [hashtable]$PoShMonConfiguration
    )

    Write-Verbose "Checking for any SharePoint tests that can be auto-ignored based on the current farm (version, etc.)..."

    # Ignore UPS Sync check for SP 2016 and up farms - no built in Sync tool exists anymore 
    $farmMajorVersion = Get-SPFarmMajorVersion $PoShMonConfiguration

    if ($farmMajorVersion -gt 15) # 15 = SP2013
    {
        Write-Verbose "Auto-ignoring 'SPUPSSyncHealth' (SharePoint User Profile Sync) - not needed for versions above SharePoint 2013..."
        $poShMonConfiguration.General.TestsToSkip += "SPUPSSyncHealth"
    }
}