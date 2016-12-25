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