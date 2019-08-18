Function Get-PlatformVersion
{
    [CmdletBinding()]
    Param(
        [parameter()]
        [hashtable]$PoShMonConfiguration,
        [string]$PlatformVersionDiscoveryFunctionName = $null
    )

    $serverNames = @()

    if ($PlatformVersionDiscoveryFunctionName -ne $null -and $PlatformVersionDiscoveryFunctionName -ne '')
    {
        $platformVersion = & $PlatformVersionDiscoveryFunctionName $PoShMonConfiguration

        Write-Verbose ("Found the following platform version: " + $platformVersion)
    }
    else {
        $platformVersion = $null

        Write-Verbose ("Platform version not found: " + $platformVersion)
    }

    return $platformVersion
}