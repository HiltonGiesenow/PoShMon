Function New-OutputHeadersHtmlBody
{
    [cmdletbinding()]
    param(
        $outputHeaders
    )

    $emailBody = ''

    foreach ($headerKey in $outputHeaders.Keys)
    {
        $header = $outputHeaders[$headerKey]
        $emailBody += '<th align="left" style="border: 1px solid #CCCCCC; background-color: #C7DAE9; color: #126AB0">' + $header + '</th>'
    }

    return $emailBody
}