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
        # Auto-Discover Servers
        $PoShMonConfiguration.General.ServerNames = Get-ServersInSPFarm $PoShMonConfiguration

        $testsToRun = Get-FinalTestsToRun -AllTests (Get-SPTests) -PoShMonConfiguration $PoShMonConfiguration

        foreach ($test in $testsToRun)
        {
            $outputValues += & ("Test-" + $test) $PoShMonConfiguration
        }
        
    } catch {
        Send-ExceptionNotifications -PoShMonConfiguration $PoShMonConfiguration -Exception $_.Exception
    } finally {
        #if ($remoteSession -ne $null)
        #    { Disconnect-RemoteSession $remoteSession -ErrorAction SilentlyContinue }
        Get-PSSession -ComputerName $PoShMonConfiguration.General.PrimaryServerName -Name $PoShMonConfiguration.General.RemoteSessionName -ConfigurationName $PoShMonConfiguration.General.ConfigurationName `
            | Remove-PSSession

        $stopWatch.Stop()
    }

    Process-Notifications -PoShMonConfiguration $PoShMonConfiguration -TestOutputValues $outputValues -TotalElapsedTime $stopWatch.Elapsed

    return $outputValues
}