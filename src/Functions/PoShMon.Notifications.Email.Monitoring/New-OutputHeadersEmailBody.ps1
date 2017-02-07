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
        $emailBody += '<th align="left" style="border: 1px solid black;">' + $header + '</th>'
    }

    return $emailBody
}