Function New-HtmlRepairOutputBody
{
    [cmdletbinding()]
    param(
        $Output
    )

    $emailSection = ''

    $title = $output.SectionHeader

    $emailSection += '<div style="width:100%; background-color: #FFFFFF;">'
    $emailSection += '<table style="border-collapse: collapse; min-width: 500px; " cellpadding="3">'
    $emailSection += '<thead><tr><th align=left style="border: 1px solid CCCCCC; background-color: #1D6097;">'
    $emailSection +=    "<h2 style=""font-size: 16px; color: #FFFFFF"">$title</h2></th></tr></thead>"

    if ($output.ContainsKey("Exception"))
    {
        $emailSection += "<tbody><tr><td>An Exception Occurred</td></tr><tr><td>$($output.Exception.ToString())</td></tr></tbody>"
    } else {
        $emailSection += "<tbody><tr><td>$($output.RepairResult)</td></tr></tbody>"
    }

    $emailSection += '</table></div><br/>'

    return $emailSection
}