Function Send-PoShMonEmail
{
    [CmdletBinding()]
    Param(
        [hashtable]$PoShMonConfiguration,
        [hashtable]$EmailNotificationSink,
        [ValidateSet("All","OnlyOnFailure","None")][string]$SendNotificationsWhen,
        [object[]]$TestOutputValues,
        [TimeSpan]$TotalElapsedTime
    )

    $emailBody = ''
            
    $emailBody += Get-EmailHeader "$($PoShMonConfiguration.General.EnvironmentName) Monitoring Report"

    $emailBody += New-MonitoringEmailOutput -SendMailWhen $SendNotificationsWhen -TestOutputValues $TestOutputValues

    $emailBody += Get-EmailFooter $PoShMonConfiguration.General.TestsToSkip $TotalElapsedTime

    Write-Verbose $EmailBody
 
    $subject = Get-EmailSubject $TestOutputValues

    Send-MailMessage -Subject $subject -Body $emailBody -BodyAsHtml -To $EmailNotificationSink.ToAddress -From $EmailNotificationSink.FromAddress -SmtpServer $EmailNotificationSink.SmtpServer #-Port $EmailNotificationSink.Port -UseSsl $EmailNotificationSink.UseSSL
}