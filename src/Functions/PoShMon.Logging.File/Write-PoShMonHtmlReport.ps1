Function Write-PoShMonHtmlReport {
    [CmdletBinding()]
    Param(
		[System.Collections.ArrayList]$PoShMonOutputValues,
		[hashtable]$PoShMonConfiguration = $null,
		[TimeSpan]$TotalElapsedTime = (New-TimeSpan),
		[string]$OutputFilePath,
		[switch]$OverwriteFileIfExists = $false
	)

	if ($PoShMonConfiguration -eq $null)
	{
		Write-Verbose "No Configuration object supplied, using Global one created previously"
		$PoShMonConfiguration = $Global:PoShMonConfiguration
	}

	if ($TotalElapsedTime -eq $null -or $TotalElapsedTime.Ticks -eq 0)
	{
		Write-Verbose "No TotalElapsedTime supplied, using Global one created previously"	
		$TotalElapsedTime = $Global:PoShMon_TotalElapsedTime
	}

	$htmlBody = New-HtmlBody -PoShMonConfiguration $PoShMonConfiguration -SendNotificationsWhen "All" `
		-TestOutputValues $PoShMonOutputValues -TotalElapsedTime $TotalElapsedTime

	$htmlBody | Out-File -FilePath $OutputFilePath -NoClobber:(!$OverwriteFileIfExists)
}