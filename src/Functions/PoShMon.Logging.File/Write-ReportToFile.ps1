Function Write-ReportToFile {
    [CmdletBinding()]
    Param(
		[Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
		[System.Collections.ArrayList]$PoShMonOutputValues,
		[hashtable]$PoShMonConfiguration = $null,
		[TimeSpan]$TotalElapsedTime = (New-TimeSpan),
		[string]$OutputFilePath,
		[boolean]$OverwriteFileIfExists = $false
	)

	if ($PoShMonConfiguration -eq $null)
	{
		Write-Verbose "No Configuration object supplied, using Global one created previously"
		$PoShMonConfiguration = $Global:PoShMonConfiguration
	}

	if ($TotalElapsedTime.Ticks -eq 0)
	{
		Write-Verbose "No TotalElapsedTime supplied, using Global one created previously"	
		$TotalElapsedTime = $Global:TotalElapsedPoShMonTime
	}

	$htmlBody = New-HtmlBody -PoShMonConfiguration $PoShMonConfiguration -SendNotificationsWhen "All" `
		-TestOutputValues $PoShMonOutputValues -TotalElapsedTime $TotalElapsedTime

	$htmlBody | Out-File -FilePath $OutputFilePath -NoClobber:(!$OverwriteFileIfExists)
}