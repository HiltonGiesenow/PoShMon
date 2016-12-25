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
        [ValidateSet("All","OnlyOnFailure","None")][string]$SendMailWhen = "All",
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

    Confirm-SendMonitoringEmail -TestOutputValues $outputValues -SkippedTests $TestsToSkip -SendMailWhen $SendMailWhen `
        -EnvironmentName $EnvironmentName -MailToList $MailToList -MailFrom $MailFrom -SMTPAddress $SMTPAddress -TotalElapsedTime $stopWatch.Elapsed

    return $outputValues
}