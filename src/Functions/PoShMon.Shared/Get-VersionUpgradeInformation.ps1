Function Get-VersionUpgradeInformation
{
    [CmdletBinding()]
    param (
        [hashtable]$PoShMonConfiguration
    )

    if ($PoShMonConfiguration.General.SkipVersionUpdateCheck)
    {
        return "Version check skipped"
    } else {
        $currentVersion = Get-Module PoShMon -ListAvailable | Select -First 1 | Sort Version 

        try {
            $galleryVersion = Find-Module PoShMon -Repository PSGallery

            if ($currentVersion.Version -lt $galleryVersion.Version)
            {
                return "New version available - run 'Update-PoShMon' command"
            } else {
                return "Latest version installed"
            }           
        }
        catch {
            return "Version Update information not available (check Internet access for RunAs account)"
        }
    }
}