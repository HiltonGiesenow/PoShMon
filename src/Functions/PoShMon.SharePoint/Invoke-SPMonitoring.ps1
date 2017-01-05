Function Invoke-SPMonitoring
{
    [CmdletBinding()]
    Param(
        [parameter(Mandatory=$true, HelpMessage="A PoShMonConfiguration instance - use New-PoShMonConfiguration to create it")]
        [hashtable]$PoShMonConfiguration
    )

    if ($PoShMonConfiguration.TypeName -ne 'PoShMon.Configuration')
        { throw "PoShMonConfiguration is not of the correct type - please use New-PoShMonConfiguration to create it" }

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

        # Memory Space
        if (!$PoShMonConfiguration.General.TestsToSkip.Contains("Memory"))
            { $outputValues += Test-Memory $PoShMonConfiguration }

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
            { $outputValues += Test-DatabaseHealth $remoteSession }

        # Distributed Cache Health
        if (!$PoShMonConfiguration.General.TestsToSkip.Contains("SPDistributedCacheHealth"))
            { $outputValues += Test-DistributedCacheStatus $remoteSession }

        # Search Health
        if (!$PoShMonConfiguration.General.TestsToSkip.Contains("SPSearchHealth"))
            { $outputValues += Test-SearchHealth $remoteSession }

        # User Profile Sync Health
        if (!$PoShMonConfiguration.General.TestsToSkip.Contains("SPUPSSyncHealth"))
            { $outputValues += Test-UserProfileSync -RemoteSession $remoteSession -PoShMonConfiguration $PoShMonConfiguration }

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