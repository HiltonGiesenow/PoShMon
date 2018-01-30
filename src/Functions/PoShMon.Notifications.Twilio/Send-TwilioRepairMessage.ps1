Function Send-TwilioRepairMessage
{
    [CmdletBinding()]
    Param(
		[hashtable]$PoShMonConfiguration,
		[object[]]$RepairOutputValues,
		[hashtable]$NotificationSink
    )

	$subject = New-ShortRepairMessageSubject -PoShMonConfiguration $PoShMonConfiguration -RepairOutputValues $RepairOutputValues
	$body = New-ShortRepairMessageBody -PoShMonConfiguration $PoShMonConfiguration -RepairOutputValues $RepairOutputValues

	Send-TwilioMessage -PoShMonConfiguration $PoShMonConfiguration -NotificationSink $NotificationSink `
							 -Subject $Subject -Body $Body -Critical $false
}