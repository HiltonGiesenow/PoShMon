Function Update-PoShMon
{
    [CmdletBinding()]
    param(
    )

    $currentVersion = Get-Module PoShMon -ListAvailable | Select -First 1 | Sort Version 

    $galleryVersion = Find-Module PoShMon -Repository PSGallery

    if ($currentVersion.Version -eq $galleryVersion.Version)
    {
        Write-Host "Latest version already installed, skipping update"
    } else {
        if ((Get-Module PoShMon))
            { Remove-Module PoShMon -ErrorAction SilentlyContinue }
        Update-Module PoShMon
        Install-Module PoShMon

        $upgradedVersion = Get-Module PoShMon -ListAvailable | Select -First 1 | Sort Version 
        
        if ($upgradedVersion.Version -eq $galleryVersion.Version)
        {
            Write-Host "PoShMon version upgrade to $($upgradedVersion.Version.ToString())"
        } else {
            "Upgrade failed"
        }
    }
}