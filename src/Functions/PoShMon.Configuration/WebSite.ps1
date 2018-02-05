Function New-WebSiteConfig
{
    [CmdletBinding()]
    param(
        [hashtable]$WebsiteDetails = @{}
    )

    if ($Script:PoShMon.ConfigurationItems.WebSite -eq $null)
        { $Script:PoShMon.ConfigurationItems.WebSite = @{} }
    else {
        throw "WebSite configuration group already created."
    }

    return @{
            TypeName = "PoShMon.ConfigurationItems.WebSite"
            WebsiteDetails = $WebsiteDetails
        }
}