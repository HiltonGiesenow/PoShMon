Function New-ShortMessageSubject
{
    [CmdletBinding()]
    Param(
        [hashtable]$PoShMonConfiguration,
        [System.Collections.ArrayList]$TestOutputValues,
        [boolean]$ShowIssueCount = $true
    )

    $subject = "[PoshMon $($PoShMonConfiguration.General.EnvironmentName) Monitoring Results"
    
    if ($ShowIssueCount)
    {
        $issueCount = 0
        foreach ($outputValue in $TestOutputValues)
            { if (($outputValue.NoIssuesFound -eq $false))
                { $issueCount++ } }

        $subject += " ($issueCount Issue(s) Found)"
    }

	$subject += "]"

    return $subject
}