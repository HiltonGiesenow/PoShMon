Function New-HtmlHeader
{
    [CmdletBinding()]
    param(
        [hashtable]$PoShMonConfiguration,
        [string]$MainTitle = "PoShMon Monitoring Report"
    )

    $emailSection = ''
    $emailSection += '<head><title>' + $ReportTitle + '</title></head>'
    $emailSection += '<body style="font-family: verdana; font-size: 12px;">'
    $emailSection += '<table width="100%" style="border-collapse: collapse; ">'
    $emailSection += '<tr><td colspan="3" style="background-color: lightgray">&nbsp;</td></tr>'
    $emailSection += '<tr><td style="background-color: lightgray">&nbsp;</td><td style="background-color: #1D6097; color: #FFFFFF; Padding: 20px;"><h1>' + $MainTitle + '</h1></td><td style="background-color: lightgray">&nbsp;</td></tr>'

    $versionText = if ($PoShMonConfiguration.General.EnvironmentVersion -eq $null) { "" } else { " (Version: $($PoShMonConfiguration.General.EnvironmentVersion.ToString()))" }

    $emailSection += '<tr><td style="background-color: lightgray">&nbsp;</td><td style="background-color: #000000; color: #FFFFFF; padding: 10px; padding-left: 20px">' + $PoShMonConfiguration.General.EnvironmentName + ' Environment' + $versionText + '</td><td style="background-color: lightgray">&nbsp;</td></tr>'
    $emailSection += '<tr><td style="background-color: lightgray">&nbsp;</td><td style="background-color: lightgray; padding-top: 20px;">' #start main body

    return $emailSection;

}