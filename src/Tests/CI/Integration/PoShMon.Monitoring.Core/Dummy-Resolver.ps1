Function Dummy-Resolver
{
    [CmdletBinding()]
    Param(
        [hashtable]$PoShMonConfiguration,
        [System.Collections.ArrayList]$TestOutputValues
    )

    $testToScanFor = $TestOutputValues | Where { $_.SectionHeader -EQ "SPServerStatus Mock" }

    if ($testToScanFor.Count -gt 0)
    {
        $testToScanFor.NoIssuesFound = $true
    }

    #return $TestOutputValues
}