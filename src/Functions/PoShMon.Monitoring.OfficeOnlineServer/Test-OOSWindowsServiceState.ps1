Function Test-OOSWindowsServiceState
{
    [CmdletBinding()]
    param (
        [hashtable]$PoShMonConfiguration
    )

    $mainOutput = Get-InitialOutputWithTimer -SectionHeader "Windows Service State" -OutputHeaders ([ordered]@{ 'DisplayName' = 'Display Name'; 'Name' = 'Name'; 'Status' = 'Status' })

    $serversWithServices = @{}
    [System.Collections.ArrayList]$defaultServiceList = @('WACSM')
    if ($PoShMonConfiguration.OperatingSystem.WindowsServices -ne $null -and $PoShMonConfiguration.OperatingSystem.WindowsServices.Count -gt 0)
        { $defaultServiceList += $PoShMonConfiguration.OperatingSystem.WindowsServices }
    if ($PoShMonConfiguration.OperatingSystem.WindowsServicesToSkip -ne $null -and $PoShMonConfiguration.OperatingSystem.WindowsServicesToSkip.Count -gt 0)
    {
        foreach ($serviceToSkip in $PoShMonConfiguration.OperatingSystem.WindowsServicesToSkip)
        {
            $defaultServiceList.Remove($serviceToSkip)
        }
    }

    $serversWithServices = @{}
    foreach ($ServerName in $PoShMonConfiguration.General.ServerNames)
    {
        $serversWithServices.Add($ServerName, $defaultServiceList)
    }

    Write-Verbose "`tGetting state of services per server..."
    foreach ($serverWithServicesKey in $serversWithServices.Keys)
    {
        $serverWithServices = $serversWithServices[$serverWithServicesKey]
        $groupedoutputItem = Test-ServiceStatePartial -ServerName $serverWithServicesKey -Services $serverWithServices

        $mainOutput.NoIssuesFound = $mainOutput.NoIssuesFound -and $groupedoutputItem.NoIssuesFound

        $mainOutput.OutputValues += $groupedoutputItem
    }

    return (Complete-TimedOutput $mainOutput)
}