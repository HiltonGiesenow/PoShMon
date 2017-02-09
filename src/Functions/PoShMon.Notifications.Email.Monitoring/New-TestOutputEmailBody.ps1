Function New-TestOutputEmailBody
{
    [cmdletbinding()]
    param(
        $Output
    )

    $emailSection = ''

    $title = $output.SectionHeader
    if ($output.ContainsKey("ElapsedTime"))
        { $title += $(" ({0:F2} Seconds)" -f $output["ElapsedTime"].TotalSeconds) }

    #$emailSection += "<p><h2>$title</h2>"
    $emailSection += "<br/>"
    $emailSection += '<p style="margin: 15px; "><table style="border-collapse: collapse; min-width: 500px; " cellpadding="3">'
    $emailSection += "<thead><tr><th align=""left"" style=""border: 1px solid CCCCCC; background-color: #1D6097;"" colspan=""$($output.OutputHeaders.Keys.Count)"">"
    $emailSection +=    "<h2 style=""font-size: 16px; color: #FFFFFF"">$title</h2>"
    $emailSection += "</th></tr></thead>"

    if ($output.ContainsKey("Exception"))
    {
        $emailSection += "<tbody><tr><td>An Exception Occurred</td></tr><tr><td>$($output.Exception.ToString())</td></tr></tbody>"
    }
    elseif ($output.OutputValues -ne $null -and $output.OutputValues.Count -gt 0 -and `
        $output.OutputValues[0].ContainsKey("GroupName")) #grouped output
    {
        foreach ($groupOutputValue in $output.OutputValues)
        {    
            #$emailSection += '<thead><tr><th align="left" style="border: 1px solid #CCCCCC; background-color: #1D6097; color: #FFFFFF" colspan="' + $output.OutputHeaders.Keys.Count + '">' + $groupOutputValue.GroupName + '</th></tr><tr>'
            $emailSection += '<thead><tr><th align="left" style="border: 1px solid #CCCCCC; background-color: #1D6097; color: #FFFFFF" colspan="2">' + $groupOutputValue.GroupName + '</th></tr></thead>'
            $emailSection += '<tbody><tr><td style="padding-left: 25px">&nbsp;</td><td><table style="border-collapse: collapse;" cellpadding="3"><thead><tr>'

            $emailSection += (New-OutputHeadersEmailBody -outputHeaders $output.OutputHeaders) + '</tr></thead><tbody>'

            $emailSection += (New-OutputValuesEmailBody -outputHeaders $output.OutputHeaders -outputValues $groupOutputValue.GroupOutputValues) + '</tbody>'

            #$emailSection += '<tr style="border: 0px;"><td style="font-size: 6px;" colspan="' + $output.OutputHeaders.Keys.Count + '">&nbsp</td></tr>'
            $emailSection += '</table></td></tbody></tr>'
        }
    # if ($output.ContainsKey("GroupBy")) {
    #     $groups = $output.OutputValues | Group $output["GroupBy"]

    #     foreach ($group in $groups)
    #     {
    #          $emailSection += '<thead><tr><th align="left" colspan="' + $output.OutputHeaders.Keys.Count + '"><h2>' + $group.Name + '</h2></th></tr><tr>'

    #          $emailSection += (New-OutputHeadersEmailBody -outputHeaders $output.OutputHeaders) + '</tr></thead><tbody>'

    #          $emailSection += (New-OutputValuesEmailBody -outputHeaders $output.OutputHeaders -outputValues $group.Group) + '</tbody>'
    #     }
    } else { #non-grouped output
        $emailSection += '<thead><tr>' + (New-OutputHeadersEmailBody -outputHeaders $output.OutputHeaders) + '</tr></thead><tbody>'

        $emailSection += (New-OutputValuesEmailBody -outputHeaders $output.OutputHeaders -outputValues $output.OutputValues) + '</tbody>'
    }

    $emailSection += '</table></p>'

    return $emailSection
}