Function New-MonitoringEmailOutput
{
    [CmdletBinding()]
    param(
        [ValidateSet("All","OnlyOnFailure","None")][string]$SendMailWhen = "All",
        $TestOutputValues
    )

    $emailSection = ''

    foreach ($testOutputValue in $testOutputValues)
    {
        if ($SendMailWhen -eq "All" -or $testOutputValue.NoIssuesFound -eq $false)
            { $emailSection += Get-EmailOutput -Output $testOutputValue }
    }

    return $emailSection
}
