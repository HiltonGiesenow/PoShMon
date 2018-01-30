Function Send-EmailMonitoringMessage
{
    [CmdletBinding()]
    Param(
		[hashtable]$PoShMonConfiguration,
		[System.Collections.ArrayList]$TestOutputValues,
		[hashtable]$NotificationSink,
		[ValidateSet("All","OnlyOnFailure","None")][string]$SendNotificationsWhen,
		[TimeSpan]$TotalElapsedTime,
        [bool]$Critical
    )

	$subject = New-HtmlSubject -PoShMonConfiguration $PoShMonConfiguration -TestOutputValues $TestOutputValues
	$body = New-HtmlBody -PoShMonConfiguration $PoShMonConfiguration -SendNotificationsWhen $SendNotificationsWhen `
							-TestOutputValues $TestOutputValues -TotalElapsedTime $TotalElapsedTime

	Send-PoShMonEmailMessage -PoShMonConfiguration $PoShMonConfiguration -NotificationSink $NotificationSink `
							 -Subject $Subject -Body $Body -Critical $Critical
}