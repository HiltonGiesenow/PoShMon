Function Invoke-MonitoringCore
{
    [CmdletBinding()]
    Param(
        [parameter(Mandatory=$true)]
        [hashtable]$PoShMonConfiguration,
        [parameter(Mandatory=$true)]
        [string[]]$TestList,
        [Parameter(HelpMessage="In the case of a Farm product, such as SharePoint, provide a function to call to auto-discover the remaining servers")]
        [string]$FarmDiscoveryFunctionName = $null,
        [string[]]$OutputOptimizationList = @()
    )

    if ($PoShMonConfiguration.TypeName -ne 'PoShMon.Configuration')
        { throw "PoShMonConfiguration is not of the correct type - please use New-PoShMonConfiguration to create it" }

    Compare-SkippedTestsToActual $PoShMonConfiguration $TestList

    $stopWatch = [System.Diagnostics.Stopwatch]::StartNew()

    try {
        # Auto-Discover Servers
        if ($FarmDiscoveryFunctionName -ne $null -and $FarmDiscoveryFunctionName -ne '')
            { $PoShMonConfiguration.General.ServerNames = & $FarmDiscoveryFunctionName $PoShMonConfiguration }

        # Perform the actual main monitoring tests
        $outputValues = $TestList | `
                            Remove-SkippedTests -PoShMonConfiguration $PoShMonConfiguration | `
                                Invoke-Tests -PoShMonConfiguration $PoShMonConfiguration

        # Resolve any output issues with all test output (e.g. High CPU might be explained because of something in another test's output)
        if ($OutputOptimizationList.Count -gt 0)
            { $outputValues = Optimize-Output $PoShMonConfiguration $outputValues $OutputOptimizationList }

    } catch {
        Send-ExceptionNotifications -PoShMonConfiguration $PoShMonConfiguration -Exception $_.Exception
    } finally {
        if ($PoShMonConfiguration.General.PrimaryServerName -ne $null -and $PoShMonConfiguration.General.PrimaryServerName -ne '')
        {
            $remoteSession = Get-PSSession -ComputerName $PoShMonConfiguration.General.PrimaryServerName -Name $PoShMonConfiguration.General.RemoteSessionName -ConfigurationName $PoShMonConfiguration.General.ConfigurationName -ErrorAction SilentlyContinue
            if ($remoteSession -ne $null)
                { Remove-PSSession $remoteSession }
        }

        $stopWatch.Stop()
    }

    Initialize-Notifications -PoShMonConfiguration $PoShMonConfiguration -TestOutputValues $outputValues -TotalElapsedTime $stopWatch.Elapsed

    return $outputValues
}