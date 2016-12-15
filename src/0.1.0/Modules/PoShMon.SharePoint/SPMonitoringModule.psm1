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
        [parameter(Mandatory=$true)][string]$PrimaryServerName,
        [string[]]$MailToList,
        [string[]]$EventLogCodes = 'Critical',
        [string]$ConfigurationName = $null,
        [bool]$SendEmail = $true,
        [string]$MailFrom,
        [string]$SMTPAddress
    )

    $emailBody = Get-EmailHeader "SharePoint Environment Monitoring Report"
    $NoIssuesFound = $true

    $remoteSession = Connect-RemoteSharePointSession -ServerName $PrimaryServerName -ConfigurationName $ConfigurationName
    
    try {
        # Auto-Discover Servers
        $ServerNames = Invoke-Command -Session $remoteSession -ScriptBlock { Get-SPServer | Where Role -ne "Invalid" | Select Name } | % { $_.Name }

        # Event Logs
        foreach ($eventLogCode in $EventLogCodes)
        {
            $eventLogOutput = Test-EventLogs -ServerNames $ServerNames -MinutesToScanHistory $MinutesToScanHistory -SeverityCode $eventLogCode
            $emailBody += Get-EmailOutputGroup -SectionHeader ($eventLogCode + " Event Log Entries") -output $eventLogOutput
            $NoIssuesFound = $NoIssuesFound -and $eventLogOutput.NoIssuesFound
        }

        # Drive Space
        $driveSpaceOutput = Test-DriveSpace -ServerNames $ServerNames
        $emailBody += Get-EmailOutputGroup -SectionHeader "Server Drive Space" -output $driveSpaceOutput
        $NoIssuesFound = $NoIssuesFound -and $driveSpaceOutput.NoIssuesFound

        # Failing Timer Jobs
        $jobHealthOutput = Invoke-Command -Session $remoteSession -ScriptBlock {
                                param($MinutesToScanHistory)
                                Test-JobHealth $MinutesToScanHistory
                            } -ArgumentList $MinutesToScanHistory
        $emailBody += Get-EmailOutput -SectionHeader "Failed Timer Jobs" -output $jobHealthOutput
        $NoIssuesFound = $NoIssuesFound -and $jobHealthOutput.NoIssuesFound

        # Server Status
        #$serverHealthOutput = Invoke-Command -Session $remoteSession -ScriptBlock {
        #                        Test-SPServerStatus
        #                      }
        $serverHealthOutput = Test-SPServerStatus
        $emailBody += Get-EmailOutput -SectionHeader "Farm Server Status" -output $serverHealthOutput
        $NoIssuesFound = $NoIssuesFound -and $serverHealthOutput.NoIssuesFound

        $searchHealthOutput = Invoke-Command -Session $remoteSession -ScriptBlock {
                                Test-SearchHealth
                              }
        $emailBody += Get-EmailOutput -SectionHeader "Search Status" -output $searchHealthOutput
        $NoIssuesFound = $NoIssuesFound -and $searchHealthOutput.NoIssuesFound
    
    } finally {
        Disconnect-RemoteSession $remoteSession
    }

    $emailBody += Get-EmailFooter

    Write-Verbose $emailBody

    if ($NoIssuesFound)
    {
        Write-Verbose "No major issues encountered, skipping email"
    } else {
        if ($SendEmail)
        {
            Send-MailMessage -Subject "[PoshMon Monitoring] Monitoring Results" -Body $emailBody -BodyAsHtml -To $MailToList -From $MailFrom -SmtpServer $SMTPAddress
        } 
    }
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
        Add-PSSnapin Microsoft.SharePoint.PowerShell
        Import-Module "X:\Admin Scripts\PoShMon_Dev\0.1.0\Modules\PoShMon.psd1" #TODO: need to improve this once PoShMon is packaged and, e.g. on PowerShellGallery
    }

    return $remoteSession
}

Function Test-SearchHealth
{
    [CmdletBinding()]
    param (
        [string]$emailBody
    )

    $NoIssuesFound = $true
    $outputHeaders = @{ 'ComponentName' = 'Component'; 'ServerName' = 'Server Name'; 'State' = 'State' }
    $outputValues = @()

    $ssa = Get-SPEnterpriseSearchServiceApplication

    $searchComponentStates = Get-SPEnterpriseSearchStatus -SearchApplication $ssa -Detailed #| Where State -ne "Active"

    $componentTopology = Get-SPEnterpriseSearchComponent -SearchTopology $ssa.ActiveTopology | Select Name,ServerName

    foreach ($searchComponentState in $searchComponentStates)
    {
        $highlight = @()

        foreach ($componentTopologyItem in $componentTopology)
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
        "NoIssuesFound" = $NoIssuesFound;
        "OutputHeaders" = $outputHeaders;
        "OutputValues" = $outputValues
        }
}
<#
    $output = Test-SearchHealth
#>

Function Test-JobHealth
{
    [CmdletBinding()]
    param (
        [int]$MinutesToScanHistory = 1440 # one day
    )

    $NoIssuesFound = $true
    $outputHeaders = @{ 'JobDefinitionTitle' = 'Job Definition Title'; 'EndTime' = 'End Time'; 'ServerName' = 'Server Name'; 'WebApplicationName' = 'Web Application Name'; 'ErrorMessage' ='Error Message' }
    $outputValues = @()

    $farm = Get-SPFarm
    $timerJobService = $farm.TimerService

    $startDate = (Get-Date).AddMinutes(-$MinutesToScanHistory) #.ToUniversalTime()

    $jobHistoryEntries = $timerJobService.JobHistoryEntries | Where-Object { $_.Status -eq "Failed" -and $_.StartTime -gt $startDate }

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
        "NoIssuesFound" = $NoIssuesFound;
        "OutputHeaders" = $outputHeaders;
        "OutputValues" = $outputValues
        }
}
<#
    $output = Test-JobHealth -MinutesToScanHistory 2000 -Verbose
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
        "NoIssuesFound" = $NoIssuesFound;
        "OutputHeaders" = $outputHeaders;
        "OutputValues" = $outputValues
        }
}
<#
    $output = Test-SPServerStatus -Verbose
#>

Function Test-DatabasesNeedingUpgrade
{
    [CmdletBinding()]
    param (
    )

    $NoIssuesFound = $true
    $outputHeaders = @{ 'DatabaseName' = 'Database Name'; 'ApplicationName' = 'Application Name'; 'NeedsUpgrade' = 'Needs Upgrade?' }
    $outputValues = @()

    $spDatabases = Get-SPDatabase

    foreach ($spDatabase in $spDatabases)
    {
        if ($spDatabase.NeedsUpgrade)
        {
            $NoIssuesFound = $false

            Write-Host ($spDatabase.DisplayName + " (" + $spDatabase.ApplicationName + ") is listed as Needing Upgrade")

            $outputItem = @{
                'DatabaseName' = $spDatabase.DisplayName;
                'ApplicationName' = $spDatabase.ApplicationName;
                'NeedsUpgrade' = $spDatabase.NeedsUpgrade
            }

            $outputValues += $outputItem
        }
    }

    return @{
        "NoIssuesFound" = $NoIssuesFound;
        "OutputHeaders" = $outputHeaders;
        "OutputValues" = $outputValues
        }
}

<#
Get-SPServiceInstance | ? {($_.service.tostring()) -eq “SPDistributedCacheService Name=AppFabricCachingService”} | select Server, Status

Get-CacheHost
    Use-CacheCluster issue

Get-CacheClusterHealth
#>