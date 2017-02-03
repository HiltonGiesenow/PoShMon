Function Test-SPWindowsServiceState
{
    [CmdletBinding()]
    param (
        #[System.Management.Automation.Runspaces.PSSession]$RemoteSession,
        [hashtable]$PoShMonConfiguration
    )

    $mainOutput = Get-InitialOutputWithTimer -SectionHeader "Windows Service State" -OutputHeaders ([ordered]@{ 'DisplayName' = 'Display Name'; 'Name' = 'Name'; 'Status' = 'Status' })

    Write-Verbose "`tGetting SharePoint service list..."
    $spServiceInstances = Invoke-RemoteCommand -PoShMonConfiguration $PoShMonConfiguration -ScriptBlock {
                            Get-SPServiceInstance | Where Service -like '* Name=*' | Select Server, Service, Status | Sort Server
                        }

    $serversWithServices = @{}
    $defaultServiceList = 'IISADMIN','SPAdminV4','SPTimerV4','SPTraceV4','SPWriterV4'
    if ($PoShMonConfiguration.OperatingSystem.WindowsServices -ne $null -and $PoShMonConfiguration.OperatingSystem.WindowsServices.Count -gt 0)
        { $defaultServiceList += $PoShMonConfiguration.OperatingSystem.WindowsServices }

    foreach ($spServiceInstance in $spServiceInstances)
    {
        # ignore non Windows services
        if ($spServiceInstance.Status.Value -eq 'Online' `
            -and $spServiceInstance.Service.Name -ne 'WSS_Administration' `
            -and $spServiceInstance.Service.Name -ne 'spworkflowtimerv4'
        )
        {
            if (!$serversWithServices.ContainsKey($spServiceInstance.Server.DisplayName))
            {
                $serversWithServices.Add($spServiceInstance.Server.DisplayName, $defaultServiceList)
            }

            $serversWithServices[$spServiceInstance.Server.DisplayName] += $spServiceInstance.Service.Name
        }
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
<#
    $output = Test-SPWindowsServiceState -RemoteSession $remoteSession -WindowsServices $WindowsServices
#>