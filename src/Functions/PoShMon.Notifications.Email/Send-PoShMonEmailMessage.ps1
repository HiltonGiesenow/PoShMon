Function Send-PoShMonEmailMessage
{
    [CmdletBinding()]
    Param(
		[hashtable]$PoShMonConfiguration,
		[hashtable]$NotificationSink,
		[string]$Subject,
		[string]$Body,
        [bool]$Critical
    )

    Write-Verbose $body

    $priority = if ($Critical) { [System.Net.Mail.MailPriority]::High } else { [System.Net.Mail.MailPriority]::Normal }

    $params = @{
        Subject = $subject
        Body = $body
        BodyAsHtml = $true
        To = $NotificationSink.ToAddress
        From = $NotificationSink.FromAddress
        Priority = $priority
        SmtpServer = $NotificationSink.SmtpServer
        ErrorVariable = "MailError"
    }

    if ($NotificationSink.SmtpCredential -ne $null)
        { $params.Add("Credential", $NotificationSink.SmtpCredential) }

    Send-MailMessage @params

    # they might be failing to send because they set the old "General.InternetAccessRunAsAccount" instead of the new Email.SmtpCredential
    if ($MailError.Count -gt 0 -and $MailError[0].Exception.Message.Contains("Relay access denied") -and `
        $PoShMonConfiguration.General.InternetAccessRunAsAccount -ne $null -and $NotificationSink.SmtpCredential -eq $null)
    {
        Write-Warning "You have set an Internet Access RunAs Account (InternetAccessRunAsAccount) but not a credential for SMTP authentication - perhaps you need to set this setting on the Notifications.Email configuration object"
    }

}