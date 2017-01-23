Function Test-ServiceState
{
    [CmdletBinding()]
    param (
        [hashtable]$PoShMonConfiguration
    )

    if ($PoShMonConfiguration.OperatingSystem -eq $null) { throw "'OperatingSystem' configuration not set properly on PoShMonConfiguration parameter." }
    if ($PoShMonConfiguration.OperatingSystem.WindowsServices.Count -eq 0) { throw "'WindowsServices' configuration not set properly on PoShMonConfiguration.OperatingSystem parameter." }

    $mainOutput = Get-InitialOutputWithTimer -SectionHeader "Windows Service State" -OutputHeaders ([ordered]@{ 'DisplayName' = 'Display Name'; 'Name' = 'Name'; 'Status' = 'Status' })

    foreach ($serverName in $PoShMonConfiguration.General.ServerNames)
    {
        $groupedoutputItem = Test-ServiceStatePartial -ServerName $serverName -Services $PoShMonConfiguration.OperatingSystem.WindowsServices

        $mainOutput.NoIssuesFound = $mainOutput.NoIssuesFound -and $groupedoutputItem.NoIssuesFound

        $mainOutput.OutputValues += $groupedoutputItem
    }

    return (Complete-TimedOutput $mainOutput)
}