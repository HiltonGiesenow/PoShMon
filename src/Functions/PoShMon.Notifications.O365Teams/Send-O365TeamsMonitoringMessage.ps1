Function Send-O365TeamsMonitoringMessage
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

	$subject = New-ShortMessageSubject -PoShMonConfiguration $PoShMonConfiguration -TestOutputValues $TestOutputValues -ShowIssueCount $true
	$body = New-ShortMessageBody -PoShMonConfiguration $PoShMonConfiguration -SendNotificationsWhen $SendNotificationsWhen `
								 -TestOutputValues $TestOutputValues -TotalElapsedTime $TotalElapsedTime

	Send-O365TeamsMessage -PoShMonConfiguration $PoShMonConfiguration -NotificationSink $NotificationSink `
						  -Subject $Subject -Body $Body -Critical $Critical
 }