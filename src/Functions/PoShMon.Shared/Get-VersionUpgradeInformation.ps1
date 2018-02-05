Function Get-VersionUpgradeInformation
{
    [CmdletBinding()]
    param (
        [hashtable]$PoShMonConfiguration
    )

    if ($PoShMonConfiguration.General.SkipVersionUpdateCheck)
    {
        return "version check skipped"
    } else {
        $currentVersion = Get-Module PoShMon -ListAvailable | Select -First 1 | Sort Version 

        try {
            $galleryVersion = Find-Module PoShMon -Repository PSGallery

            if ($currentVersion.Version -lt $galleryVersion.Version)
            {
                return "new version available - run 'Update-PoShMon' command"
            } else {
                return "latest version installed"
            }           
        }
        catch {
            return "version update information not available (check Internet access for RunAs account)"
        }
    }
}