Function Send-O365TeamsExceptionMessage
{
    [CmdletBinding()]
    Param(
		[hashtable]$PoShMonConfiguration,
		[hashtable]$NotificationSink,
        [System.Exception]$Exception,
		[string]$SubjectAction,
		[string]$BodyAction
    )

	$subject = New-ShortExceptionMessageSubject -PoShMonConfiguration $PoShMonConfiguration -Action $SubjectAction
	$body = New-ShortExceptionMessageBody -Exception $Exception -Action $BodyAction

	Send-O365TeamsMessage -PoShMonConfiguration $PoShMonConfiguration -NotificationSink $NotificationSink `
							 -Subject $Subject -Body $Body -Critical $true
}