Function New-SharePointConfig
{
    [CmdletBinding()]
    param(
        [string]$CentralAdminUrl = ''
    )

    if ($Script:PoShMon.ConfigurationItems.SharePoint -eq $null)
        { $Script:PoShMon.ConfigurationItems.SharePoint = @{} }
    else {
        throw "SharePoint configuration group already created."
    }

    if ($CentralAdminUrl -ne '')
    {
        if ($CentralAdminUrl.EndsWith("/"))
            { $CentralAdminUrl = $CentralAdminUrl.Substring(0, $CentralAdminUrl.Length - 1) }
        elseif ($CentralAdminUrl.ToLower().EndsWith("default.aspx"))
            { $CentralAdminUrl = $CentralAdminUrl.ToLower().Replace("/default.aspx", "") }
    }

    return @{
            TypeName = "PoShMon.ConfigurationItems.SharePoint"
            CentralAdminUrl = $CentralAdminUrl
        }
}