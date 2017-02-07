Function New-OutputHeadersEmailBody
{
    [cmdletbinding()]
    param(
        $outputHeaders
    )

    $emailBody = ''

    foreach ($headerKey in $outputHeaders.Keys)
    {
        $header = $outputHeaders[$headerKey]
        $emailBody += '<th align="left" style="border: 1px solid black; font-size: 12px; padding: 0px; background-color: #5585d1">' + $header + '</th>'
    }

    return $emailBody
}