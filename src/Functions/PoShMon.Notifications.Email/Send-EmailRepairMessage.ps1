Function Send-EmailRepairMessage
{
    [CmdletBinding()]
    Param(
		[hashtable]$PoShMonConfiguration,
		[object[]]$RepairOutputValues,
		[hashtable]$NotificationSink
    )

	$subject = New-HtmlRepairSubject -PoShMonConfiguration $PoShMonConfiguration -RepairOutputValues $RepairOutputValues
	$body = New-HtmlRepairBody -PoShMonConfiguration $PoShMonConfiguration -RepairOutputValues $RepairOutputValues

	Send-PoShMonEmailMessage -PoShMonConfiguration $PoShMonConfiguration -NotificationSink $NotificationSink `
							 -Subject $Subject -Body $Body -Critical $false
}