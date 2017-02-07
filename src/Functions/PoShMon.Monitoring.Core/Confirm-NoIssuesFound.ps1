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

        if ($testOutputValue.NoIssuesFound -eq $false)
            { break; }
    }

    return $NoIssuesFound
}