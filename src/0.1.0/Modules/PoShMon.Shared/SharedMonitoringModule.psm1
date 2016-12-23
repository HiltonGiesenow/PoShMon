Function Format-Gigs
{
    [cmdletbinding()]
    param(
        [parameter(ValueFromPipeline)]$freeSpaceRaw
    )

    $gigsValue = ($freeSpaceRaw/1MB)
   
    return ("{0:F0}" -f $gigsValue) 
    #$([Math]::Round($disk.Size/1GB,2))
}

Function Connect-RemoteSession
{
    [cmdletbinding()]
    param(
        [parameter(Mandatory=$true)][string]$ServerName,
        [string]$ConfigurationName = $null
    )

    if ($ConfigurationName -ne $null)
        { $remoteSession = New-PSSession -ComputerName $ServerName -ConfigurationName $ConfigurationName }
    else
        { $remoteSession = New-PSSession -ComputerName $ServerName }

    return $remoteSession
}

Function Disconnect-RemoteSession
{
    [cmdletbinding()]
    param(
        $RemoteSession
    )

    Remove-PSSession $RemoteSession
}

Function Get-EmailOutput
{
    [cmdletbinding()]
    param(
        $Output
    )

    $emailSection = ''

    $title = $output.SectionHeader
    if ($output.ContainsKey("ElapsedTime"))
        { $title += $(" ({0:F2} Seconds)" -f $output["ElapsedTime"].TotalSeconds) }

    $emailSection += "<p><h1>$title</h1>"
    $emailSection += '<table border="1">'

    if ($output.OutputValues -ne $null -and $output.OutputValues.Count -gt 0 -and `
        $output.OutputValues[0].ContainsKey("GroupName")) #grouped output
    {
        foreach ($groupOutputValue in $output.OutputValues)
        {    
            $emailSection += '<thead><tr><th align="left" colspan="' + $output.OutputHeaders.Keys.Count + '"><h2>' + $groupOutputValue.GroupName + '</h2></th></tr><tr>'

            $emailSection += (Get-OutputHeadersEmailOutput -outputHeaders $output.OutputHeaders) + '</tr></thead><tbody>'

            $emailSection += (Get-OutputValuesEmailOutput -outputHeaders $output.OutputHeaders -outputValues $groupOutputValue.GroupOutputValues) + '</tbody>'
        }

    } else { #non-grouped output
        $emailSection += '<thead><tr>' + (Get-OutputHeadersEmailOutput -outputHeaders $output.OutputHeaders) + '</tr></thead><tbody>'

        $emailSection += (Get-OutputValuesEmailOutput -outputHeaders $output.OutputHeaders -outputValues $output.OutputValues) + '</tbody>'
    }

    $emailSection += '</table>'

    return $emailSection
}

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

Function Get-OutputValuesEmailOutput
{
    [cmdletbinding()]
    param(
        $outputHeaders,
        $outputValues
    )
    
    $emailSection = ''

    foreach ($outputValue in $outputValues)
    {
        $emailSection += '<tr>'

        foreach ($headerKey in $outputHeaders.Keys)
        {
            $fieldValue = $outputValue[$headerKey]
            if ($outputValue['Highlight'] -ne $null -and $outputValue['Highlight'].Contains($headerKey)) {
                $style = ' style="font-weight: bold; color: red"'
            } else {
                $style = ''
            }

            $align = 'left'
            $temp = ''
            if ([decimal]::TryParse($fieldValue, [ref]$temp))
                { $align = 'right' }

            $emailSection += '<td valign="top"' + $style + ' align="' + $align +'">' + $fieldValue + '</td>'
        }

        $emailSection += '</tr>'
    }

    return $emailSection
}

Function Get-EmailHeader
{
    [CmdletBinding()]
    param(
        [string]$ReportTitle = "PoShMon Monitoring Report"
    )

    $emailSection = '<head><title>' + $ReportTitle + '</title>
</head>
<body>
<h1>' + $ReportTitle + '</h1>'

    return $emailSection;

}

Function Get-EmailFooter
{
    [CmdletBinding()]
    param(
        [TimeSpan]$TotalElapsedTime
    )

    $emailSection = ''

    if ($TotalElapsedTime -ne $null)
         { $emailSection += "<p>Total Elapsed Time (Seconds): $("{0:F2}" -f $TotalElapsedTime.TotalSeconds) ($("{0:F2}" -f $TotalElapsedTime.TotalMinutes) Minutes)</p>" }

    $emailSection += '</body>'

    return $emailSection;
}

Function Confirm-NoIssuesFound
{
    [CmdletBinding()]
    param(
        $TestOutputValues
    )

    $NoIssuesFound = $true

    foreach ($testOutputValue in $testOutputValues)
    {
        $NoIssuesFound = $NoIssuesFound -and $testOutputValue.NoIssuesFound
    }

    return $NoIssuesFound
}

Function New-MonitoringEmailOutput
{
    [CmdletBinding()]
    param(
        $SendEmailOnlyOnFailure,
        $TestOutputValues
    )

    $emailSection = ''

    foreach ($testOutputValue in $testOutputValues)
    {
        if ($SendEmailOnlyOnFailure -eq $false -or $testOutputValue.NoIssuesFound -eq $false)
            { $emailSection += Get-EmailOutput -Output $testOutputValue }
    }

    return $emailSection
}

Function Confirm-SendMonitoringEmail
{
    [CmdletBinding()]
    param(
        $TestOutputValues,        
        $SendEmailOnlyOnFailure,
        $SendEmail,
        $EnvironmentName,
        $EmailBody,
        $MailToList,
        $MailFrom,
        $SMTPAddress,
        [TimeSpan]$TotalElapsedTime
    )

    $noIssuesFound = Confirm-NoIssuesFound $TestOutputValues

    if ($NoIssuesFound -and $SendEmailOnlyOnFailure -eq $true)
    {
        Write-Verbose "No major issues encountered, skipping email"
    } else {
        if ($SendEmail)
        {
            $emailBody = ''
            
            $emailBody += Get-EmailHeader "$EnvironmentName Monitoring Report"

            $emailBody += New-MonitoringEmailOutput -SendEmailOnlyOnFailure $SendEmailOnlyOnFailure -TestOutputValues $TestOutputValues

            $emailBody += Get-EmailFooter $TotalElapsedTime

            Write-Verbose $EmailBody
 
            Send-MailMessage -Subject "[PoshMon Monitoring] $EnvironmentName Monitoring Results" -Body $emailBody -BodyAsHtml -To $MailToList -From $MailFrom -SmtpServer $SMTPAddress
        }
    }
}