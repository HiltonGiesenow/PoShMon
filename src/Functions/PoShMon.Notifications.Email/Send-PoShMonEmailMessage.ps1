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
    }

    if ($PoShMonConfiguration.General.InternetAccessRunAsAccount -ne $null)
        { $params.Add("Credential", $PoShMonConfiguration.General.InternetAccessRunAsAccount) }

    Send-MailMessage @params
}