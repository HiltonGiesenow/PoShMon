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
