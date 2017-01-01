Function Send-PoShMonEmail
{
    [CmdletBinding()]
    Param(
        [hashtable]$PoShMonConfiguration,
        [hashtable]$EmailNotificationSink,
        [string]$Subject,
        [string]$Body
    )

    Write-Verbose $Body

    Send-MailMessage -Subject $Subject -Body $Body -BodyAsHtml -To $EmailNotificationSink.ToAddress -From $EmailNotificationSink.FromAddress -SmtpServer $EmailNotificationSink.SmtpServer #-Port $EmailNotificationSink.Port -UseSsl $EmailNotificationSink.UseSSL
}