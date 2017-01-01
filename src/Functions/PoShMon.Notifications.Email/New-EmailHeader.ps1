Function New-EmailHeader
{
    [CmdletBinding()]
    param(
        [string]$ReportTitle = "PoShMon Monitoring Report"
    )

    $emailSection = '<head><title>' + $ReportTitle + '</title></head><body><h1>' + $ReportTitle + '</h1>'

    return $emailSection;

}