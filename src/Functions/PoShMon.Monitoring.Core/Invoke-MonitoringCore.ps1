Function Invoke-MonitoringCore
{
    [CmdletBinding()]
    Param(
        [parameter()]
        [hashtable]$PoShMonConfiguration,
        [parameter(Mandatory=$true)]
        [string[]]$TestList,
        [string]$TestsToAutoIgnoreFunctionName = $null,
        [Parameter(HelpMessage="In the case of a Farm product, such as SharePoint, provide a function to call to auto-discover the remaining servers")]
        [string]$FarmDiscoveryFunctionName = $null,
        [string]$PlatformVersionDiscoveryFunctionName = $null,
        [string[]]$OutputOptimizationList = @(),
        [string[]]$MergesList = @()
    )

    if ($PoShMonConfiguration -eq $null) { $PoShMonConfiguration = New-PoShMonConfiguration {} }
    
    if ($PoShMonConfiguration.TypeName -ne 'PoShMon.Configuration')
        { throw "PoShMonConfiguration is not of the correct type - please use New-PoShMonConfiguration to create it" }

    Compare-SkippedTestsToActual $PoShMonConfiguration $TestList

    $stopWatch = [System.Diagnostics.Stopwatch]::StartNew()

    try {

        $Global:PoShMon_GlobalException = $null # clear any previous run's global exception 

        # Auto-Discover Servers if none are supplied
        if ($PoShMonConfiguration.General.ServerNames -eq $null)
            { $PoShMonConfiguration.General.ServerNames = AutoDiscover-ServerNames $PoShMonConfiguration $FarmDiscoveryFunctionName }

        $PoShMonConfiguration.General.EnvironmentVersion = TryAutoDiscover-PlatformVersion $PoShMonConfiguration $PlatformVersionDiscoveryFunctionName

        # Check for any tests that can be auto-ignored (e.g. wrong version of platform)
        if ($TestsToAutoIgnoreFunctionName -ne $null -and $TestsToAutoIgnoreFunctionName -ne '')
            { & $TestsToAutoIgnoreFunctionName $PoShMonConfiguration }

        # Perform the actual main monitoring tests
        $outputValues = $TestList | `
                            Remove-SkippedTests -PoShMonConfiguration $PoShMonConfiguration | `
                                Invoke-Tests -PoShMonConfiguration $PoShMonConfiguration

        # Resolve any output issues with all test output (e.g. High CPU might be explained because of something in another test's output)
        #if ($OutputOptimizationList.Count -gt 0)
            #{ 
                #$outputValues = 
                Optimize-Output $PoShMonConfiguration $outputValues $OutputOptimizationList
             #}

        $outputValues = Invoke-Merges $PoShMonConfiguration $outputValues $MergesList

    } catch {
        $Global:PoShMon_GlobalException = $_.Exception
        Send-ExceptionNotifications -PoShMonConfiguration $PoShMonConfiguration -Exception $_.Exception
    } finally {
        if ($PoShMonConfiguration.General.PrimaryServerName -ne $null -and $PoShMonConfiguration.General.PrimaryServerName -ne '')
        {
            $remoteSession = $Global:PoShMon_RemoteSession #Get-PSSession -ComputerName $PoShMonConfiguration.General.PrimaryServerName -Name $PoShMonConfiguration.General.RemoteSessionName -ConfigurationName $PoShMonConfiguration.General.ConfigurationName -ErrorAction SilentlyContinue
            if ($remoteSession -ne $null)
                { Remove-PSSession $remoteSession }
        }

        $stopWatch.Stop()
    }

	$Global:PoShMon_TotalElapsedTime = $stopWatch.Elapsed

    Initialize-Notifications -PoShMonConfiguration $PoShMonConfiguration -TestOutputValues $outputValues -TotalElapsedTime $stopWatch.Elapsed

    return $outputValues
}