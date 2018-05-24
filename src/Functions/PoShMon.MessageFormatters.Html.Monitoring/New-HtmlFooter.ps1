Function New-HtmlFooter
{
    [CmdletBinding()]
    param(
        [hashtable]$PoShMonConfiguration,
        [TimeSpan]$TotalElapsedTime
    )

    $emailSection = ''

    $emailSection += '</td><td style="background-color: lightgray">&nbsp;</td></tr>' #end main body

    $emailSection += '<tr><td style="background-color: lightgray">&nbsp;</td><td style="background-color: #000000; color: #FFFFFF; padding: 20px">'

    $SkippedTests = $PoShMonConfiguration.General.TestsToSkip

    $emailSection += '<b>Skipped Tests:</b> '
    if ($SkippedTests.Count -eq 0)
        { $emailSection += "None" }
    else
        { $emailSection += ($SkippedTests -join ", ") + "" }

    if ($TotalElapsedTime -ne $null -and $TotalElapsedTime.Ticks -gt 0)
         { $emailSection += "<br/><b>Total Elapsed Time (Seconds):</b> $("{0:F2}" -f $TotalElapsedTime.TotalSeconds) ($("{0:F2}" -f $TotalElapsedTime.TotalMinutes) Minutes)" }

    $currentVersion = Get-Module PoShMon -ListAvailable | Select -First 1 | Sort Version #TODO: This logic might be wrong - might need to do the sort first. Needs to be tested

    $emailSection += '</td><td style="background-color: lightgray">&nbsp;</td></tr>' #end main body
    $emailSection += '<tr><td style="background-color: lightgray">&nbsp;</td><td style="background-color: #1D6097; color: #FFFFFF; padding: 20px" align="center">'
    $emailSection += "PoShMon Version $($currentVersion.Version.ToString()) ($(Get-VersionUpgradeInformation $PoShMonConfiguration))"
    $emailSection += '</td><td style="background-color: lightgray">&nbsp;</td></tr>'
    $emailSection += '<tr><td colspan="3" style="background-color: lightgray">&nbsp;</td></tr>'
    $emailSection += '</table><br/>'
    $emailSection += '</body>'

    return $emailSection;
}