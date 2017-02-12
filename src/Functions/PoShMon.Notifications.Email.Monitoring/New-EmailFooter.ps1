Function New-EmailFooter
{
    [CmdletBinding()]
    param(
        [hashtable]$PoShMonConfiguration,
        [TimeSpan]$TotalElapsedTime
    )

    $emailSection = ''

    $emailSection += '</td><td>&nbsp;</td></tr>' #end main body

    $emailSection += '<tr><td>&nbsp;</td><td style="background-color: #000000; color: #FFFFFF; padding: 20px">'

    $SkippedTests = $PoShMonConfiguration.General.TestsToSkip

    $emailSection += '<b>Skipped Tests:</b> '
    if ($SkippedTests.Count -eq 0)
        { $emailSection += "None" }
    else
        { $emailSection += ($SkippedTests -join ", ") + "" }

    if ($TotalElapsedTime -ne $null)
         { $emailSection += "<br/><b>Total Elapsed Time (Seconds):</b> $("{0:F2}" -f $TotalElapsedTime.TotalSeconds) ($("{0:F2}" -f $TotalElapsedTime.TotalMinutes) Minutes)" }

    $currentVersion = Get-Module PoShMon -ListAvailable | Select -First 1 | Sort Version 

    $emailSection += '</td><td>&nbsp;</td></tr>' #end main body
    $emailSection += '<tr><td>&nbsp;</td><td style="background-color: #1D6097; color: #FFFFFF; padding: 20px" align="center">'
    $emailSection += "PoShMon Version $($currentVersion.Version.ToString()) ($(Get-VersionUpgradeInformation $PoShMonConfiguration))"
    $emailSection += '</td><td>&nbsp;</td></tr>'
    $emailSection += '</table>'
    $emailSection += '</body>'

    return $emailSection;
}