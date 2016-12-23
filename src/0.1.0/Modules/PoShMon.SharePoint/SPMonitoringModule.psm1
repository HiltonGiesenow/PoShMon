Function Invoke-SPMonitoring
{
    [CmdletBinding()]
    Param(
        #[parameter(Mandatory=$true, HelpMessage=”Path to file”)]
        [string]$EnvironmentName = "SharePoint",        
        [int]$MinutesToScanHistory = 15,
        [string]$PrimaryServerName = 'localhost',
        [string[]]$MailToList,
        [string[]]$EventLogCodes = 'Critical',
        [string[]]$TestsToSkip = @(),
        [hashtable]$WebsiteDetails = @{},
        [string[]]$SpecialWindowsServices = $null,
        [string]$ConfigurationName = $null,
        [bool]$SendEmail = $true,
        [bool]$SendEmailOnlyOnFailure = $false,
        [string]$MailFrom,
        [string]$SMTPAddress
    )

    $stopWatch = [System.Diagnostics.Stopwatch]::StartNew()
    $outputValues = @()

    $remoteSession = Connect-RemoteSharePointSession -ServerName $PrimaryServerName -ConfigurationName $ConfigurationName
    
    try {
        # Auto-Discover Servers
        $ServerNames = Invoke-Command -Session $remoteSession -ScriptBlock { Get-SPServer | Where Role -ne "Invalid" | Select Name } | % { $_.Name }

        # Event Logs
        if (!$TestsToSkip.Contains("EventLogs"))
        {
            foreach ($eventLogCode in $EventLogCodes)
                { $outputValues += Test-EventLogs -ServerNames $ServerNames -MinutesToScanHistory $MinutesToScanHistory -SeverityCode $eventLogCode }
        }

        # Drive Space
        if (!$TestsToSkip.Contains("DriveSpace"))
            { $outputValues += Test-DriveSpace -ServerNames $ServerNames }

        # Server Status
        if (!$TestsToSkip.Contains("SPServerStatus"))
            { $outputValues += Test-SPServerStatus -ServerNames $ServerNames -ConfigurationName $ConfigurationName }
        
        # Windows Service State
        if (!$TestsToSkip.Contains("WindowsServiceState"))
            { $outputValues += Test-SPWindowsServiceState -RemoteSession $remoteSession -SpecialWindowsServices $SpecialWindowsServices }
        
        # Failing Timer Jobs
        if (!$TestsToSkip.Contains("SPFailingTimerJobs"))
            { $outputValues += Test-JobHealth -RemoteSession $remoteSession -MinutesToScanHistory $MinutesToScanHistory }

        # Database Health
        if (!$TestsToSkip.Contains("SPDatabaseHealth"))
            { $outputValues += Test-DatabaseHealth -RemoteSession $remoteSession }

        # Search Health
        if (!$TestsToSkip.Contains("SPSearchHealth"))
            { $outputValues += Test-SearchHealth -RemoteSession $remoteSession }

        # Distributed Cache Health
        if (!$TestsToSkip.Contains("SPDistributedCacheHealth"))
            { $outputValues += Test-DistributedCacheStatus -RemoteSession $remoteSession }

        # Web Tests
        if (!$TestsToSkip.Contains("WebTests"))
        {
            foreach ($websiteDetailKey in $WebsiteDetails.Keys)
            {
                $websiteDetail = $WebsiteDetails[$websiteDetailKey]
                $outputValues += Test-WebSite -SiteUrl $WebsiteDetailKey -TextToLocate $websiteDetail -ServerNames $ServerNames -ConfigurationName $ConfigurationName
            }
        }
    } finally {
        Disconnect-RemoteSession $remoteSession
        
        $stopWatch.Stop()
    }

    Confirm-SendMonitoringEmail -TestOutputValues $outputValues -SkippedTests $TestsToSkip -SendEmailOnlyOnFailure $SendEmailOnlyOnFailure -SendEmail $SendEmail `
        -EnvironmentName $EnvironmentName -MailToList $MailToList -MailFrom $MailFrom -SMTPAddress $SMTPAddress -TotalElapsedTime $stopWatch.Elapsed

    return $outputValues
}

Function Connect-RemoteSharePointSession
{
    [cmdletbinding()]
    param(
        [parameter(Mandatory=$true)][string]$ServerName,
        [string]$ConfigurationName = $null
    )

    $remoteSession = Connect-RemoteSession @PSBoundParameters

    Invoke-Command -Session $remoteSession -ScriptBlock {
        Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
        #Import-Module "X:\Admin Scripts\PoShMon_Dev\0.1.0\Modules\PoShMon.psd1" #TODO: need to improve this once PoShMon is packaged and, e.g. on PowerShellGallery
    }

    return $remoteSession
}

Function Test-SearchHealth
{
    [CmdletBinding()]
    param (
        [System.Management.Automation.Runspaces.PSSession]$RemoteSession
    )

    $stopWatch = [System.Diagnostics.Stopwatch]::StartNew()

    Write-Verbose "Testing Search Health..."

    $sectionHeader = "Search Status"
    $NoIssuesFound = $true
    $outputHeaders = @{ 'ComponentName' = 'Component'; 'ServerName' = 'Server Name'; 'State' = 'State' }
    $outputValues = @()

    $remoteComponents = Invoke-Command -Session $RemoteSession -ScriptBlock {
        $ssa = Get-SPEnterpriseSearchServiceApplication

        $searchComponentStates = Get-SPEnterpriseSearchStatus -SearchApplication $ssa -Detailed #| Where State -ne "Active"

        $componentTopology = Get-SPEnterpriseSearchComponent -SearchTopology $ssa.ActiveTopology | Select Name,ServerName

        return @{
            "SearchComponentStates" = $searchComponentStates;
            "ComponentTopology" = $componentTopology
        }
    }

    foreach ($searchComponentState in $remoteComponents.SearchComponentStates)
    {
        $highlight = @()

        foreach ($componentTopologyItem in $remoteComponents.ComponentTopology)
        {
            if ($componentTopologyItem.Name.ToLower() -eq $searchComponentState.Name.ToLower())
            {
                Write-Verbose ($componentTopologyItem.Name + " is in the following state: " + $searchComponentState.State)

                if ($searchComponentState.State -ne "Active")
                {
                    $highlight += 'State'
                }

                $outputItem = @{
                    'ComponentName' = $componentTopologyItem.Name;
                    'ServerName' = $componentTopologyItem.ServerName;
                    'State' = $searchComponentState.State;
                    'Highlight' = $highlight
                }

                $outputValues += $outputItem
            }
        }
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
    $output = Test-SearchHealth $remoteSession
#>

Function Test-JobHealth
{
    [CmdletBinding()]
    param (
        [System.Management.Automation.Runspaces.PSSession]$RemoteSession,
        [int]$MinutesToScanHistory = 1440 # one day
    )

    $stopWatch = [System.Diagnostics.Stopwatch]::StartNew()

    Write-Verbose "Testing Timer Job Health..."

    $sectionHeader = "Timer Job Health"
    $NoIssuesFound = $true
    $outputHeaders = @{ 'JobDefinitionTitle' = 'Job Definition Title'; 'EndTime' = 'End Time'; 'ServerName' = 'Server Name'; 'WebApplicationName' = 'Web Application Name'; 'ErrorMessage' ='Error Message' }
    $outputValues = @()

    $startDate = (Get-Date).AddMinutes(-$MinutesToScanHistory) #.ToUniversalTime()

    $jobHistoryEntries = Invoke-Command -Session $RemoteSession -ScriptBlock {
                                param($StartDate)

                                $farm = Get-SPFarm
                                $timerJobService = $farm.TimerService

                                $jobHistoryEntries = $timerJobService.JobHistoryEntries | Where-Object { $_.Status -eq "Failed" -and $_.StartTime -gt $StartDate }

                                return $jobHistoryEntries
                            } -ArgumentList $startDate

    if ($jobHistoryEntries.Count -gt 0)
    {
        $NoIssuesFound = $false

        foreach ($jobHistoryEntry in $jobHistoryEntries)
        {
            Write-Verbose ($jobHistoryEntry.JobDefinitionTitle + " at " + $jobHistoryEntry.EndTime + " on " + $jobHistoryEntry.ServerName + " for " + $jobHistoryEntry.WebApplicationName + " : " + $jobHistoryEntry.ErrorMessage)
            $outputItem = @{
                'JobDefinitionTitle' = $jobHistoryEntry.JobDefinitionTitle;
                'EndTime' = $jobHistoryEntry.EndTime;
                'ServerName' = $jobHistoryEntry.ServerName;
                'WebApplicationName' = $jobHistoryEntry.WebApplicationName;
                'ErrorMessage' = $jobHistoryEntry.ErrorMessage
            }

            $outputValues += $outputItem
        }
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
    $output = Test-JobHealth -RemoteSession $remoteSession -MinutesToScanHistory 2000 -Verbose
    Persist-Output $output
    Get-EmailOutput $output
#>

<#Function Test-SPServerStatus
{
    [CmdletBinding()]
    param (
    )

    $NoIssuesFound = $true
    $outputHeaders = @{ 'ServerName' = 'Server Name'; 'Role' = 'Role'; 'NeedsUpgrade' = 'Needs Upgrade?'; 'Status' ='Status' }
    $outputValues = @()

    #$farm = Get-SPFarm
    #$farm.BuildVersion

    $servers = Get-SPServer | Where Role -ne "Invalid" # removes DB and SMTP servers

    foreach ($server in $servers) # $farm.Servers
    {
        #$server.Role -> Invalid for non SP Servers

        $highlight = @()

        if ($server.NeedsUpgrade)
        {
            $needsUpgradeValue = "Yes"
            $highlight += 'NeedsUpgrade'
            $NoIssuesFound = $false
            Write-Verbose ($server.DisplayName + " is listed as Needing Upgrade")
        } else {
            $needsUpgradeValue = "No"
        }

        $outputItem = @{
            'ServerName' = $server.DisplayName;
            'NeedsUpgrade' = $needsUpgradeValue;
            'Status' = $server.Status.ToString();
            'Role' = $server.Role.ToString();
            'Highlight' = $highlight
        }

        $outputValues += $outputItem

        if ($server.Status -ne "Online")
        {
            $NoIssuesFound = $false

            Write-Verbose ($server.DisplayName + " is in status " + $server.Status)
        }
    }

    return @{
        "NoIssuesFound" = $NoIssuesFound;
        "OutputHeaders" = $outputHeaders;
        "OutputValues" = $outputValues
        }
}
#>
Function Test-SPServerStatus
{
    [CmdletBinding()]
    param (
        [string[]]$ServerNames,
        [string]$ConfigurationName = $null
    )

    $stopWatch = [System.Diagnostics.Stopwatch]::StartNew()

    Write-Verbose "Testing Server Statuses..."

    $sectionHeader = "Farm Server Status"
    $NoIssuesFound = $true
    $outputHeaders = @{ 'ServerName' = 'Server Name'; 'Role' = 'Role'; 'NeedsUpgrade' = 'Needs Upgrade?'; 'Status' ='Status' }
    $outputValues = @()

    #$farm = Get-SPFarm
    #$farm.BuildVersion

    foreach ($ServerName in $ServerNames) # $farm.Servers
    {
        try {
            $remoteSession = Connect-RemoteSession -ServerName $ServerName -ConfigurationName $ConfigurationName

            $server = Invoke-Command -Session $remoteSession -ScriptBlock {
                                        Add-PSSnapin Microsoft.SharePoint.PowerShell
                                        Get-SPServer | Where Address -eq $env:COMPUTERNAME
                                    }
        } finally {
            Disconnect-RemoteSession $remoteSession
        }

        $highlight = @()

        if ($server.NeedsUpgrade)
        {
            $needsUpgradeValue = "Yes"
            $highlight += 'NeedsUpgrade'
            $NoIssuesFound = $false
            Write-Verbose ($server.DisplayName + " is listed as Needing Upgrade")
        } else {
            $needsUpgradeValue = "No"
        }

        if ($server.Status -ne 'Online')
        {
            $highlight += 'Status'
            $NoIssuesFound = $false
            Write-Verbose ($server.DisplayName + " is not listed as Online")
        }

        $outputItem = @{
            'ServerName' = $server.DisplayName;
            'NeedsUpgrade' = $needsUpgradeValue;
            'Status' = $server.Status.ToString();
            'Role' = $server.Role.ToString();
            'Highlight' = $highlight
        }

        $outputValues += $outputItem

        if ($server.Status -ne "Online")
        {
            $NoIssuesFound = $false

            Write-Verbose ($server.DisplayName + " is in status " + $server.Status)
        }
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
    $output = Test-SPServerStatus -Verbose
#>

Function Test-SPWindowsServiceState
{
    [CmdletBinding()]
    param (
        [System.Management.Automation.Runspaces.PSSession]$RemoteSession,
        [string[]]$SpecialWindowsServices
    )

    $stopWatch = [System.Diagnostics.Stopwatch]::StartNew()

    Write-Verbose "Getting Windows Service State..."

    Write-Verbose "`tGetting SharePoint service list..."
    $spServiceInstances = Invoke-Command -Session $remoteSession -ScriptBlock {
                            Get-SPServiceInstance | Where Service -like '* Name=*' | Select Server, Service, Status | Sort Server
                        }
    
    $sectionHeader = "Windows Service State"
    $NoIssuesFound = $true
    $outputHeaders = @{ 'DisplayName' = 'Display Name'; 'Name' = 'Name'; 'Status' = 'Status' }
    $outputValues = @()
    
    $serversWithServices = @{}
    $defaultServiceList = 'IISADMIN','SPAdminV4','SPTimerV4','SPTraceV4','SPWriterV4'
    if ($SpecialWindowsServices -ne $null -and $SpecialWindowsServices.Count -gt 0)
        { $defaultServiceList += $SpecialWindowsServices }

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

Function Test-DatabaseHealth
{
    [CmdletBinding()]
    param (
        [System.Management.Automation.Runspaces.PSSession]$RemoteSession
    )

    $stopWatch = [System.Diagnostics.Stopwatch]::StartNew()

    Write-Verbose "Testing Database Health..."

    $sectionHeader = "Database Status"
    $NoIssuesFound = $true
    $outputHeaders = @{ 'DatabaseName' = 'Database Name'; 'Size' = 'Size (MB)'; 'NeedsUpgrade' = 'Needs Upgrade?' }
    $outputValues = @()

    $spDatabases = Invoke-Command -Session $RemoteSession -ScriptBlock {
                                return Get-SPDatabase
                            }

    foreach ($spDatabase in $spDatabases)
    {
        $highlight = @()

        if ($spDatabase.NeedsUpgrade)
        {
            $NoIssuesFound = $false

            Write-Verbose ($spDatabase.DisplayName + " (" + $spDatabase.ApplicationName + ") is listed as Needing Upgrade")

            $highlight += 'NeedsUpgrade'
        }

        $outputItem = @{
            'DatabaseName' = $spDatabase.DisplayName;
            'NeedsUpgrade' = &{if($spDatabase.NeedsUpgrade) {"Yes"} else {"No"}};
            'Size' = ($spDatabase.DiskSizeRequired | Format-Gigs);
            'Highlight' = $highlight
        }

        $outputValues += $outputItem
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
    $output = Test-DatabaseHealth $remoteSession -Verbose
#>

Function Test-DistributedCacheStatus
{
    [CmdletBinding()]
    param (
        [System.Management.Automation.Runspaces.PSSession]$RemoteSession
    )

    $stopWatch = [System.Diagnostics.Stopwatch]::StartNew()

    Write-Verbose "Testing Distributed Cache Health..."
    $sectionHeader = "Distributed Cache Status"
    $NoIssuesFound = $true
    $outputHeaders = @{ 'Server' = 'Server'; 'Status' = 'Status' }
    $outputValues = @()

    $cacheServers = Invoke-Command -Session $RemoteSession -ScriptBlock {
                                return Get-SPServiceInstance | ? {($_.service.tostring()) -eq “SPDistributedCacheService Name=AppFabricCachingService”} | select Server, Status
                            }
    # Possible extensions:
    <#
    Use-CacheCluster
        Get-CacheHost

        Get-CacheClusterHealth
    #>

    foreach ($cacheServer in $cacheServers)
    {
        $highlight = @()

        if ($cacheServer.Status.Value -ne 'Online')
        {
            $NoIssuesFound = $false

            Write-Verbose ($cacheServer.Server.DisplayName + " is listed as " + $cacheServer.Status)

            $highlight += 'Status'
        }

        $outputItem = @{
            'Server' = $cacheServer.Server.DisplayName;
            'Status' = $cacheServer.Status.Value;
            'Highlight' = $highlight
        }

        $outputValues += $outputItem
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
    $output = Test-DistributedCacheStatus $remoteSession -Verbose
#>