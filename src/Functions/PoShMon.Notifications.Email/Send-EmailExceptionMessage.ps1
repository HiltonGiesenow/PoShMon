Function Send-EmailExceptionMessage
{
    [CmdletBinding()]
    Param(
		[hashtable]$PoShMonConfiguration,
		[hashtable]$NotificationSink,
        [System.Exception]$Exception,
		[string]$SubjectAction,
		[string]$BodyAction
    )

	$subject = New-HtmlExceptionSubject -PoShMonConfiguration $PoShMonConfiguration -Action $SubjectAction
	$body = New-HtmlExceptionBody -PoShMonConfiguration $PoShMonConfiguration -Exception $Exception -Action $BodyAction

	Send-PoShMonEmailMessage -PoShMonConfiguration $PoShMonConfiguration -NotificationSink $NotificationSink `
							 -Subject $Subject -Body $Body -Critical $true
}