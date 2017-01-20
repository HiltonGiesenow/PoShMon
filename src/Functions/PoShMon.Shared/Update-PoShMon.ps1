Function Update-PoShMon
{
    [CmdletBinding()]
    param(
        [string[]]$SkippedTests = @(),
        [TimeSpan]$TotalElapsedTime
    )

    $currentVersion = Get-Module PoShMon -ListAvailable | Select -First 1 | Sort Version 

    $galleryVersion = Find-Module PoShMon -Repository PSGallery

    if ($currentVersion.Version -eq $galleryVersion.Version)
    {
        Write-Host "Latest version already installed, skipping update"
    } else {
        Remove-Module PoShMon
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