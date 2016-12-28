Function Invoke-SPMonitoring
{
    [CmdletBinding()]
    Param(
        [parameter(Mandatory=$true, HelpMessage="A PoShMonConfiguration instance - use New-PoShMonConfiguration to create it")]
        [hashtable]$PoShMonConfiguration
    )

    $stopWatch = [System.Diagnostics.Stopwatch]::StartNew()
    $outputValues = @()

    $remoteSession = Connect-RemoteSharePointSession -ServerName $PoShMonConfiguration.General.PrimaryServerName -ConfigurationName $PoShMonConfiguration.General.ConfigurationName
    
    try {
        # Auto-Discover Servers
        $ServerNames = Invoke-Command -Session $remoteSession -ScriptBlock { Get-SPServer | Where Role -ne "Invalid" | Select Name } | % { $_.Name }

        # Event Logs
        if (!$PoShMonConfiguration.General.TestsToSkip.Contains("EventLogs"))
        {
            foreach ($eventLogCode in $PoShMonConfiguration.OperatingSystem.EventLogCodes)
                { $outputValues += Test-EventLogs -ServerNames $ServerNames -MinutesToScanHistory $PoShMonConfiguration.General.MinutesToScanHistory-SeverityCode $eventLogCode }
        }

        # Drive Space
        if (!$PoShMonConfiguration.General.TestsToSkip.Contains("DriveSpace"))
            { $outputValues += Test-DriveSpace -ServerNames $ServerNames }

        # Server Status
        if (!$PoShMonConfiguration.General.TestsToSkip.Contains("SPServerStatus"))
            { $outputValues += Test-SPServerStatus -ServerNames $ServerNames -ConfigurationName $PoShMonConfiguration.General.ConfigurationName }
        
        # Windows Service State
        if (!$PoShMonConfiguration.General.TestsToSkip.Contains("WindowsServiceState"))
            { $outputValues += Test-SPWindowsServiceState -RemoteSession $remoteSession -SpecialWindowsServices $PoShMonConfiguration.OperatingSystem.SpecialWindowsServices }
        
        # Failing Timer Jobs
        if (!$PoShMonConfiguration.General.TestsToSkip.Contains("SPFailingTimerJobs"))
            { $outputValues += Test-JobHealth -RemoteSession $remoteSession -MinutesToScanHistory $PoShMonConfiguration.General.MinutesToScanHistory }

        # Database Health
        if (!$PoShMonConfiguration.General.TestsToSkip.Contains("SPDatabaseHealth"))
            { $outputValues += Test-DatabaseHealth -RemoteSession $remoteSession }

        # Search Health
        if (!$PoShMonConfiguration.General.TestsToSkip.Contains("SPSearchHealth"))
            { $outputValues += Test-SearchHealth -RemoteSession $remoteSession }

        # Distributed Cache Health
        if (!$PoShMonConfiguration.General.TestsToSkip.Contains("SPDistributedCacheHealth"))
            { $outputValues += Test-DistributedCacheStatus -RemoteSession $remoteSession }

        # Web Tests
        if (!$PoShMonConfiguration.General.TestsToSkip.Contains("WebTests"))
        {
            foreach ($websiteDetailKey in $PoShMonConfiguration.WebSite.WebsiteDetails.Keys)
            {
                $websiteDetail = $PoShMonConfiguration.WebSite.WebsiteDetails[$websiteDetailKey]
                $outputValues += Test-WebSite -SiteUrl $WebsiteDetailKey -TextToLocate $websiteDetail -ServerNames $ServerNames -ConfigurationName $PoShMonConfiguration.General.ConfigurationName
            }
        }
    } finally {
        Disconnect-RemoteSession $remoteSession
        
        $stopWatch.Stop()
    }

    Process-Notifications -PoShMonConfiguration $PoShMonConfiguration -TestOutputValues $outputValues -TotalElapsedTime $stopWatch.Elapsed
    #Confirm-SendMonitoringEmail -TestOutputValues $outputValues -SkippedTests $PoShMonConfiguration.General.TestsToSkip -SendMailWhen $SendMailWhen `
    #    -EnvironmentName $EnvironmentName -MailToList $MailToList -MailFrom $MailFrom -SMTPAddress $SMTPAddress -TotalElapsedTime $stopWatch.Elapsed

    return $outputValues
}