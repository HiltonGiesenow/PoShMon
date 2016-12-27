Function Confirm-SendMonitoringEmail
{
    [CmdletBinding()]
    param(
        $TestOutputValues,
        $SkippedTests,
        [ValidateSet("All","OnlyOnFailure","None")][string]$SendMailWhen = "All",
        $EnvironmentName,
        $EmailBody,
        $MailToList,
        $MailFrom,
        $SMTPAddress,
        [TimeSpan]$TotalElapsedTime
    )

    $noIssuesFound = Confirm-NoIssuesFound $TestOutputValues

    if ($NoIssuesFound -and $SendMailWhen -eq "OnlyOnFailure")
    {
        Write-Verbose "No major issues encountered, skipping email"
    } else {
        if ($SendMailWhen -ne "None")
        {
            $emailBody = ''
            
            $emailBody += Get-EmailHeader "$EnvironmentName Monitoring Report"

            $emailBody += New-MonitoringEmailOutput -SendMailWhen $SendMailWhen -TestOutputValues $TestOutputValues

            $emailBody += Get-EmailFooter $SkippedTests $TotalElapsedTime

            Write-Verbose $EmailBody
 
            $subject = Get-EmailSubject $TestOutputValues

            Send-MailMessage -Subject $subject -Body $emailBody -BodyAsHtml -To $MailToList -From $MailFrom -SmtpServer $SMTPAddress
        }
    }
}