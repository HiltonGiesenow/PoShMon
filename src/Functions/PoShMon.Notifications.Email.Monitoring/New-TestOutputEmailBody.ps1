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

    #$emailSection += "<p><h1>$title</h1>"
    $emailSection += '<p><table style="border-collapse: collapse; border: 1px solid black;">'
    $emailSection += "<tr><thead><tr><th align=""left"" style=""border: 1px solid black; background-color: #0e47a3;"" colspan=""$($output.OutputHeaders.Keys.Count)"">"
    $emailSection += "<h1 style=""font-size: 14px; padding:0px; color: #FFFFFF"">$title</h1>"
    $emailSection += "</th></tr></thead></tr>"

    if ($output.ContainsKey("Exception"))
    {
        $emailSection += "<tbody><tr><td>An Exception Occurred</td></tr><tr><td>$($output.Exception.ToString())</td></tr></tbody>"
    }
    elseif ($output.OutputValues -ne $null -and $output.OutputValues.Count -gt 0 -and `
        $output.OutputValues[0].ContainsKey("GroupName")) #grouped output
    {
        foreach ($groupOutputValue in $output.OutputValues)
        {    
            $emailSection += '<thead><tr><th align="left" style="border: 1px solid black; background-color: #5585d1" colspan="' + $output.OutputHeaders.Keys.Count + '">' + $groupOutputValue.GroupName + '</th></tr><tr>'

            $emailSection += (New-OutputHeadersEmailBody -outputHeaders $output.OutputHeaders) + '</tr></thead><tbody>'

            $emailSection += (New-OutputValuesEmailBody -outputHeaders $output.OutputHeaders -outputValues $groupOutputValue.GroupOutputValues) + '</tbody>'
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