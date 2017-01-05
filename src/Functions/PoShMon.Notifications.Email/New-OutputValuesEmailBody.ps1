Function New-OutputValuesEmailBody
{
    [cmdletbinding()]
    param(
        $outputHeaders,
        $outputValues
    )
    
    $emailSection = ''

    Add-Type -AssemblyName System.Web

    foreach ($outputValue in $outputValues)
    {
        $emailSection += '<tr>'

        foreach ($headerKey in $outputHeaders.Keys)
        {
            $fieldValue = $outputValue[$headerKey] #Would need to change to something like $outputValue.psobject.Properties["Message"].Value if this changes to a pscustomobject
            if ($outputValue['Highlight'] -ne $null -and $outputValue['Highlight'].Contains($headerKey)) {
                $style = ' style="font-weight: bold; color: red"'
            } else {
                $style = ''
            }

            $align = 'left'
            $temp = ''
            if ([decimal]::TryParse($fieldValue, [ref]$temp))
                { $align = 'right' }

            $fieldValue = [System.Web.HttpUtility]::HtmlEncode($fieldValue)

            $emailSection += '<td valign="top"' + $style + ' align="' + $align +'">' + $fieldValue + '</td>'
        }

        $emailSection += '</tr>'
    }

    return $emailSection
}