Function New-HtmlExceptionBody
{
    [CmdletBinding()]
    Param(
		[hashtable]$PoShMonConfiguration,		
        [System.Exception]$Exception,
        [string]$Action = "monitor"
    )

	$emailBody = ""
	
    $emailBody += New-HtmlHeader $PoShMonConfiguration 'PoShMon Monitoring - <span style="color:darkred">Exception Occurred</span>'

    $emailBody += '<div style="width:99%; border: 5px solid #FFFFFF; background-color: #FCCFC5; padding: 5px">'

    $emailBody += "<p><strong>An exception occurred while trying to $Action the environment.</strong></p>"
    $emailBody += "<p>Details: $($Exception.ToString())</p>"

    $emailBody += '</div><br/>'
	
    $emailBody += New-HtmlFooter $PoShMonConfiguration (New-TimeSpan)
    
    return $emailBody
}