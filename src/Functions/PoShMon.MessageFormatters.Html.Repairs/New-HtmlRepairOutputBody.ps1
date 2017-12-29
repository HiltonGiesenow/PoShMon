Function New-HtmlRepairOutputBody
{
    [cmdletbinding()]
    param(
        $Output
    )

    $emailSection = ''

    $title = $output.SectionHeader

    $emailSection += "<p><h1>$title</h1>"
    $emailSection += '<table border="1">'

    if ($output.ContainsKey("Exception"))
    {
        $emailSection += "<tbody><tr><td>An Exception Occurred</td></tr><tr><td>$($output.Exception.ToString())</td></tr></tbody>"
    } else {
        $emailSection += "<tbody><tr><td>$($output.RepairResult)</td></tr></tbody>"
    }

    $emailSection += '</table>'

    return $emailSection
}