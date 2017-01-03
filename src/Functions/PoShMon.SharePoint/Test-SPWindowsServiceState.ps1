Function Test-SPWindowsServiceState
{
    [CmdletBinding()]
    param (
        [System.Management.Automation.Runspaces.PSSession]$RemoteSession,
        [hashtable]$PoShMonConfiguration
    )

    $stopWatch = [System.Diagnostics.Stopwatch]::StartNew()

    Write-Verbose "Getting Windows Service State..."

    Write-Verbose "`tGetting SharePoint service list..."
    $spServiceInstances = Invoke-Command -Session $remoteSession -ScriptBlock {
                            Get-SPServiceInstance | Where Service -like '* Name=*' | Select Server, Service, Status | Sort Server
                        }
    
    $sectionHeader = "Windows Service State"
    $NoIssuesFound = $true
    $outputHeaders = [ordered]@{ 'DisplayName' = 'Display Name'; 'Name' = 'Name'; 'Status' = 'Status' }
    $outputValues = @()
    
    $serversWithServices = @{}
    $defaultServiceList = 'IISADMIN','SPAdminV4','SPTimerV4','SPTraceV4','SPWriterV4'
    if ($PoShMonConfiguration.OperatingSystem.SpecialWindowsServices -ne $null -and $PoShMonConfiguration.OperatingSystem.SpecialWindowsServices.Count -gt 0)
        { $defaultServiceList += $PoShMonConfiguration.OperatingSystem.SpecialWindowsServices }

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

        $NoIssuesFound = $NoIssuesFound -and $groupedoutputItem.NoIssuesFound

        $outputValues += $groupedoutputItem
    }

    $stopWatch.Stop()

    return @{
        "SectionHeader" = $sectionHeader;
        "NoIssuesFound" = $NoIssuesFound;
        "OutputHeaders" = $outputHeaders;
        "OutputValues" = $outputValues;
        "ElapsedTime" = $stopWatch.Elapsed;
        }
}
<#
    $output = Test-SPWindowsServiceState -RemoteSession $remoteSession -SpecialWindowsServices $SpecialWindowsServices
#>