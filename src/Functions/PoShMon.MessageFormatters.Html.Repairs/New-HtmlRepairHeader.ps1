Function New-HtmlRepairHeader
{
    [CmdletBinding()]
    param(
        [string]$ReportTitle = "PoShMon Repairs Report"
    )

    $emailSection = '<head><title>' + $ReportTitle + '</title></head><body><h1>' + $ReportTitle + '</h1>'

    return $emailSection;

}