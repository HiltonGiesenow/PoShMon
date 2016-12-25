Function Get-OutputHeadersEmailOutput
{
    [cmdletbinding()]
    param(
        $outputHeaders
    )

    $emailBody = ''

    foreach ($headerKey in $outputHeaders.Keys)
    {
        $header = $outputHeaders[$headerKey]
        $emailBody += '<th align="left">' + $header + '</th>'
    }

    return $emailBody
}