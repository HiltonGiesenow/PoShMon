Function New-EmailHeader
{
    [CmdletBinding()]
    param(
        [hashtable]$PoShMonConfiguration
    )

    $emailSection = ''
    $emailSection += '<head><title>' + $ReportTitle + '</title></head>'
    $emailSection += '<body style="font-family: verdana; font-size: 12px; background-color: lightgray">'
    $emailSection += '<br/><table width="100%" style="border-collapse: collapse;">'
    $emailSection += '<tr><td>&nbsp;</td><td style="background-color: #1D6097; color: #FFFFFF; Padding: 20px;"><h1>PoShMon Monitoring Report</h1></td><td>&nbsp;</td></tr>'
    $emailSection += '<tr><td>&nbsp;</td><td style="background-color: #000000; color: #FFFFFF; padding: 10px; padding-left: 20px">' + $PoShMonConfiguration.General.EnvironmentName + ' Environment</td><td>&nbsp;</td></tr>'
    $emailSection += '<tr><td>&nbsp;</td><td style="padding-top: 20px;">' #start main body

    return $emailSection;

}