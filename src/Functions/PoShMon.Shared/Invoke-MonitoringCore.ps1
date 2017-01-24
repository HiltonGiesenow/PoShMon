Function Invoke-MonitoringCore
{
    [CmdletBinding()]
    Param(
        [parameter(Mandatory=$true)]
        [hashtable]$PoShMonConfiguration,
        [parameter(Mandatory=$true)]
        [string[]]$TestList,
        [Parameter(HelpMessage="In the case of a Farm product, such as SharePoint, provide a function to call to auto-discover the remaining servers")]
        [string]$FarmDiscoveryFunctionName = $null
    )

    if ($PoShMonConfiguration.TypeName -ne 'PoShMon.Configuration')
        { throw "PoShMonConfiguration is not of the correct type - please use New-PoShMonConfiguration to create it" }

    $stopWatch = [System.Diagnostics.Stopwatch]::StartNew()
    

    try {
        # Auto-Discover Servers
        if ($FarmDiscoveryFunctionName -ne $null -and $FarmDiscoveryFunctionName -ne '')
            { $PoShMonConfiguration.General.ServerNames = & $FarmDiscoveryFunctionName $PoShMonConfiguration }

        $outputValues = $TestList | `
                            Remove-SkippedTests -PoShMonConfiguration $PoShMonConfiguration | `
                                Invoke-Tests -PoShMonConfiguration $PoShMonConfiguration

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