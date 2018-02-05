Function Send-PushbulletExceptionMessage
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

	Send-PushbulletMessage -PoShMonConfiguration $PoShMonConfiguration -NotificationSink $NotificationSink `
							 -Subject $Subject -Body $Body -Critical $true
}