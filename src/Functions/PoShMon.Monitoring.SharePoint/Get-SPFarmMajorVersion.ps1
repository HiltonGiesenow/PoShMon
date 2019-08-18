Function Get-SPFarmMajorVersion
{
    [CmdletBinding()]
    param (
        [hashtable]$PoShMonConfiguration
    )

    Write-Verbose "Checking SharePoint farm major version..."

    # Ignore UPS Sync check for SP 2016 and up farms - no built in Sync tool exists anymore 
    # $farmMajorVersion = Invoke-RemoteCommand -PoShMonConfiguration $PoShMonConfiguration -ScriptBlock {
    #                         return (Get-SPFarm).BuildVersion.Major
    #                     }

    $farmVersion = Get-SPFarmVersion $PoShMonConfiguration
    $farmMajorVersion = $farmVersion.Major

    $versionTitle = ""

    if ($farmMajorVersion -eq 14) { $versionTitle = "2010" }
    elseif ($farmMajorVersion -eq 15) { $versionTitle = "2013" }
    elseif ($farmMajorVersion -eq 16) { $versionTitle = "2016" }
    elseif ($farmMajorVersion -eq 17) { $versionTitle = "2019" }

    Write-Verbose "Found version $farmMajorVersion (SharePoint $versionTitle)"

    return $farmMajorVersion
}