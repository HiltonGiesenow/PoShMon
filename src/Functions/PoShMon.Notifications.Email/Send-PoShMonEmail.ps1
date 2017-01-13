Function Send-PoShMonEmail
{
    [CmdletBinding()]
    Param(
        [hashtable]$PoShMonConfiguration,
        [hashtable]$EmailNotificationSink,
        [string]$Subject,
        [string]$Body,
        [bool]$Critical
    )

    Write-Verbose $Body

    $priority = if ($Critical) { [System.Net.Mail.MailPriority]::High } else { [System.Net.Mail.MailPriority]::Normal }

    Send-MailMessage -Subject $Subject -Body $Body -BodyAsHtml -To $EmailNotificationSink.ToAddress -From $EmailNotificationSink.FromAddress -Priority $priority -SmtpServer $EmailNotificationSink.SmtpServer #-Port $EmailNotificationSink.Port -UseSsl $EmailNotificationSink.UseSSL
}