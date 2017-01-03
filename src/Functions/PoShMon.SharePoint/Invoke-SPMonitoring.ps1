Function Invoke-SPMonitoring
{
    [CmdletBinding()]
    Param(
        [parameter(Mandatory=$true, HelpMessage="A PoShMonConfiguration instance - use New-PoShMonConfiguration to create it")]
        [hashtable]$PoShMonConfiguration
    )

    $stopWatch = [System.Diagnostics.Stopwatch]::StartNew()
    $outputValues = @()

    try {
        $remoteSession = Connect-RemoteSharePointSession -ServerName $PoShMonConfiguration.General.PrimaryServerName -ConfigurationName $PoShMonConfiguration.General.ConfigurationName
    
        #$PSBoundParameters.RemoteSession = $remoteSession

        # Auto-Discover Servers
        $PoShMonConfiguration.General.ServerNames = Invoke-Command -Session $remoteSession -ScriptBlock {
                                                        Get-SPServer | Where Role -ne "Invalid" | Select -ExpandProperty Name }

        # Event Logs
        if (!$PoShMonConfiguration.General.TestsToSkip.Contains("EventLogs"))
            { $outputValues += Test-EventLogs $PoShMonConfiguration }

        # Drive Space
        if (!$PoShMonConfiguration.General.TestsToSkip.Contains("DriveSpace"))
            { $outputValues += Test-DriveSpace $PoShMonConfiguration }

        # Server Status
        if (!$PoShMonConfiguration.General.TestsToSkip.Contains("SPServerStatus"))
            { $outputValues += Test-SPServerStatus $PoShMonConfiguration }
        
        # Windows Service State
        if (!$PoShMonConfiguration.General.TestsToSkip.Contains("WindowsServiceState"))
            { $outputValues += Test-SPWindowsServiceState -RemoteSession $remoteSession -PoShMonConfiguration $PoShMonConfiguration }
        
        # Failing Timer Jobs
        if (!$PoShMonConfiguration.General.TestsToSkip.Contains("SPFailingTimerJobs"))
            { $outputValues += Test-JobHealth -RemoteSession $remoteSession -PoShMonConfiguration $PoShMonConfiguration }

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
            { $outputValues += Test-WebSites $PoShMonConfiguration }

    } catch {
        Send-ExceptionNotifications -PoShMonConfiguration $PoShMonConfiguration -Exception $_.Exception
    } finally {
        if ($remoteSession -ne $null)
            { Disconnect-RemoteSession $remoteSession -ErrorAction SilentlyContinue }
        
        $stopWatch.Stop()
    }

    Process-Notifications -PoShMonConfiguration $PoShMonConfiguration -TestOutputValues $outputValues -TotalElapsedTime $stopWatch.Elapsed

    return $outputValues
}