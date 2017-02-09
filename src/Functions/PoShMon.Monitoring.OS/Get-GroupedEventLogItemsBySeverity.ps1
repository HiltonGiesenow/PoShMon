Function Get-GroupedEventLogItemsBySeverity
{
    param (
        [string]$ComputerName,
        [string]$SeverityCode = "Warning",
        $WmiStartDate
    )

   $events = Get-WmiObject win32_NTLogEvent -ComputerName $ComputerName -filter "(logfile='Application') AND (Type ='$severityCode') And TimeGenerated > '$wmiStartDate'" | Group-Object EventCode, Message

   return $events
}