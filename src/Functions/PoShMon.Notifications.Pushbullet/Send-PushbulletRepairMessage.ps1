Function Send-PushbulletRepairMessage
{
    [CmdletBinding()]
    Param(
		[hashtable]$PoShMonConfiguration,
		[object[]]$RepairOutputValues,
		[hashtable]$NotificationSink
    )

	$subject = New-ShortRepairMessageSubject -PoShMonConfiguration $PoShMonConfiguration -RepairOutputValues $RepairOutputValues
	$body = New-ShortRepairMessageBody -PoShMonConfiguration $PoShMonConfiguration -RepairOutputValues $RepairOutputValues

	Send-PushbulletMessage -PoShMonConfiguration $PoShMonConfiguration -NotificationSink $NotificationSink `
							 -Subject $Subject -Body $Body -Critical $false
}