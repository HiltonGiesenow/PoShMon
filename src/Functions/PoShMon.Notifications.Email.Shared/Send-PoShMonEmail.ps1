Function Send-PoShMonEmail
{
    [CmdletBinding()]
    Param(
        [hashtable]$PoShMonConfiguration,
        [hashtable]$EmailNotificationSink,
        [string]$Subject,
        [string]$Body,
        [bool]$Critical = $false
    )

    Write-Verbose $Body

    $priority = if ($Critical) { [System.Net.Mail.MailPriority]::High } else { [System.Net.Mail.MailPriority]::Normal }

    $params = @{
        Subject = $Subject
        Body = $Body
        BodyAsHtml = $true
        To = $EmailNotificationSink.ToAddress
        From = $EmailNotificationSink.FromAddress
        Priority = $priority
        SmtpServer = $EmailNotificationSink.SmtpServer
    }

    if ($PoShMonConfiguration.General.InternetAccessRunAsAccount -ne $null)
        { $params.Add("Credential", $PoShMonConfiguration.General.InternetAccessRunAsAccount) }

    #Send-MailMessage -Subject $Subject -Body $Body -BodyAsHtml -To $EmailNotificationSink.ToAddress -From $EmailNotificationSink.FromAddress -Priority $priority -SmtpServer $EmailNotificationSink.SmtpServer #-Port $EmailNotificationSink.Port -UseSsl $EmailNotificationSink.UseSSL
    Send-MailMessage @params
}