<#
Function Discover-ServersInFarm
{
    [cmdletbinding()]
    param(
        [string]$InitialServerName
    )

    $servers = Get-SPServer 
}
#>

Function Invoke-SPMonitoring
{
    [CmdletBinding()]
    Param(
        #[parameter(Mandatory=$true, HelpMessage=”Path to file”)]
        [int]$MinutesToScanHistory = 15,
        [string]$PrimaryServerName = 'localhost',
        [string[]]$MailToList,
        [string[]]$EventLogCodes = 'Critical',
        [hashtable]$WebsiteDetails = @{},
        [string[]]$SpecialWindowsServices = $null,
        [string]$ConfigurationName = $null,
        [bool]$SendEmail = $true,
        [bool]$SendEmailOnlyOnFailure = $false,
        [string]$MailFrom,
        [string]$SMTPAddress
    )

    $emailBody = Get-EmailHeader "SharePoint Environment Monitoring Report"
    $NoIssuesFound = $true
    $outputValues = @() 

    $remoteSession = Connect-RemoteSharePointSession -ServerName $PrimaryServerName -ConfigurationName $ConfigurationName
    
    try {
        # Auto-Discover Servers
        $ServerNames = Invoke-Command -Session $remoteSession -ScriptBlock { Get-SPServer | Where Role -ne "Invalid" | Select Name } | % { $_.Name }

        # Event Logs
        foreach ($eventLogCode in $EventLogCodes)
        {
            $eventLogOutput = Test-EventLogs -ServerNames $ServerNames -MinutesToScanHistory $MinutesToScanHistory -SeverityCode $eventLogCode
            if ($SendEmailOnlyOnFailure -eq $false -or $eventLogOutput.NoIssuesFound -eq $false)
                { $emailBody += Get-EmailOutputGroup -output $eventLogOutput }
            $NoIssuesFound = $NoIssuesFound -and $eventLogOutput.NoIssuesFound
            $outputValues += $eventLogOutput
        }

        # Drive Space
        $driveSpaceOutput = Test-DriveSpace -ServerNames $ServerNames
        if ($SendEmailOnlyOnFailure -eq $false -or $driveSpaceOutput.NoIssuesFound -eq $false)
            { $emailBody += Get-EmailOutputGroup -Output $driveSpaceOutput }
        $NoIssuesFound = $NoIssuesFound -and $driveSpaceOutput.NoIssuesFound
        $outputValues += $driveSpaceOutput
        
        # Server Status
        $serverHealthOutput = Test-SPServerStatus -ServerNames $ServerNames -ConfigurationName $ConfigurationName
        if ($serverHealthOutput.NoIssuesFound -eq $false)
            { $emailBody += Get-EmailOutput -Output $serverHealthOutput }
        $NoIssuesFound = $NoIssuesFound -and $serverHealthOutput.NoIssuesFound
        $outputValues += $serverHealthOutput

        #Windows Service State
        $windowsServiceHealthOutput = Test-SPWindowsServiceState -RemoteSession $remoteSession -SpecialWindowsServices $SpecialWindowsServices
        if ($windowsServiceHealthOutput.NoIssuesFound -eq $false)
            { $emailBody += Get-EmailOutput -Output $windowsServiceHealthOutput }
        $NoIssuesFound = $NoIssuesFound -and $windowsServiceHealthOutput.NoIssuesFound
        $outputValues += $windowsServiceHealthOutput

        $jobHealthOutput = Test-JobHealth -RemoteSession $remoteSession -MinutesToScanHistory $MinutesToScanHistory
        if ($jobHealthOutput.NoIssuesFound -eq $false)
            { $emailBody += Get-EmailOutput -Output $jobHealthOutput }
        $NoIssuesFound = $NoIssuesFound -and $jobHealthOutput.NoIssuesFound
        $outputValues += $jobHealthOutput

        $searchHealthOutput = Test-SearchHealth -RemoteSession $remoteSession
        if ($SendEmailOnlyOnFailure -eq $false -or $searchHealthOutput.NoIssuesFound -eq $false)
            { $emailBody += Get-EmailOutput -Output $searchHealthOutput } 
        $NoIssuesFound = $NoIssuesFound -and $searchHealthOutput.NoIssuesFound
        $outputValues += $searchHealthOutput

        $databaseHealthOutput = Test-DatabaseHealth -RemoteSession $remoteSession
        if ($SendEmailOnlyOnFailure -eq $false -or $databaseHealthOutput.NoIssuesFound -eq $false)
            { $emailBody += Get-EmailOutput -Output $databaseHealthOutput }
        $NoIssuesFound = $NoIssuesFound -and $databaseHealthOutput.NoIssuesFound
        $outputValues += $databaseHealthOutput

        $cacheHealthOutput = Test-DistributedCacheStatus -RemoteSession $remoteSession
        if ($SendEmailOnlyOnFailure -eq $false -or $cacheHealthOutput.NoIssuesFound -eq $false)
            { $emailBody += Get-EmailOutput -Output $cacheHealthOutput }
        $NoIssuesFound = $NoIssuesFound -and $cacheHealthOutput.NoIssuesFound
        $outputValues += $cacheHealthOutput

        foreach ($websiteDetailKey in $WebsiteDetails.Keys)
        {
            $websiteDetail = $WebsiteDetails[$websiteDetailKey]
            $websiteTestOutput = Test-WebSite -SiteUrl $WebsiteDetailKey -TextToLocate $websiteDetail -ServerNames $ServerNames -ConfigurationName $ConfigurationName
            if ($SendEmailOnlyOnFailure -eq $false -or $websiteTestOutput.NoIssuesFound -eq $false)
                { $emailBody += Get-EmailOutput -SectionHeader ("Web Test - " + $websiteDetailKey) -output $websiteTestOutput }
            $NoIssuesFound = $NoIssuesFound -and $websiteTestOutput.NoIssuesFound
            $outputValues += $websiteTestOutput
        }
    } finally {
        Disconnect-RemoteSession $remoteSession
    }

    $emailBody += Get-EmailFooter

    Write-Verbose $emailBody

    if ($NoIssuesFound -and $SendEmailOnlyOnFailure -eq $true)
    {
        Write-Verbose "No major issues encountered, skipping email"
    } else {
        if ($SendEmail)
        {
            Send-MailMessage -Subject "[PoshMon Monitoring] Monitoring Results" -Body $emailBody -BodyAsHtml -To $MailToList -From $MailFrom -SmtpServer $SMTPAddress
        } 
    }

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

    return @{
        "SectionHeader" = $sectionHeader;
        "NoIssuesFound" = $NoIssuesFound;
        "OutputHeaders" = $outputHeaders;
        "OutputValues" = $outputValues
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

    return @{
        "SectionHeader" = $sectionHeader;
        "NoIssuesFound" = $NoIssuesFound;
        "OutputHeaders" = $outputHeaders;
        "OutputValues" = $outputValues
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

    return @{
        "SectionHeader" = $sectionHeader;
        "NoIssuesFound" = $NoIssuesFound;
        "OutputHeaders" = $outputHeaders;
        "OutputValues" = $outputValues
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

    $spServiceInstances = Invoke-Command -Session $remoteSession -ScriptBlock {
                            Get-SPServiceInstance | Where Service -like '* Name=*' | Select Server, Service, Status | Sort Server
                        }
    
    $sectionHeader = "Windows Service State"
    $NoIssuesFound = $true
    $outputHeaders = @{ 'DisplayName' = 'Display Name'; 'Name' = 'Name'; 'Status' = 'Status' }
    $outputValues = @()

    Write-Verbose "Getting Windows Service State..."
    
    $serversWithServices = @{}
    $defaultServiceList = 'IISADMIN','SPAdminV4','SPTimerV4','SPTraceV4','SPWriterV4' + $SpecialWindowsServices

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

    foreach ($serverWithServicesKey in $serversWithServices.Keys)
    {
        $serverWithServices = $serversWithServices[$serverWithServicesKey]
        $groupedoutputItem = Test-ServiceStatePartial -ServerName $serverWithServicesKey -Services $serverWithServices

        $outputValues += $groupedoutputItem
    }

    return @{
        "SectionHeader" = $sectionHeader;
        "NoIssuesFound" = $NoIssuesFound;
        "OutputHeaders" = $outputHeaders;
        "OutputValues" = $outputValues
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

    return @{
        "SectionHeader" = $sectionHeader;
        "NoIssuesFound" = $NoIssuesFound;
        "OutputHeaders" = $outputHeaders;
        "OutputValues" = $outputValues
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

    return @{
        "SectionHeader" = $sectionHeader;
        "NoIssuesFound" = $NoIssuesFound;
        "OutputHeaders" = $outputHeaders;
        "OutputValues" = $outputValues
        }
}

<#
    $output = Test-DistributedCacheStatus $remoteSession -Verbose
#>