Function New-PushbulletMessageSubject
{
    [CmdletBinding()]
    Param(
        [hashtable]$PoShMonConfiguration,
        [object[]]$TestOutputValues
    )

    $issueCount = 0
    foreach ($outputValue in $TestOutputValues)
        { if (($outputValue.NoIssuesFound -eq $false))
            { $issueCount++ } }

    $subject = "[PoshMon $EnvironmentName Monitoring Results ($issueCount Issue(s) Found)]"

    return $subject
}