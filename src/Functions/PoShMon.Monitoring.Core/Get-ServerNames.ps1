Function Get-ServerNames
{
    [CmdletBinding()]
    Param(
        [parameter()]
        [hashtable]$PoShMonConfiguration,
        [string]$FarmDiscoveryFunctionName = $null
    )

    $serverNames = @()

    if ($FarmDiscoveryFunctionName -ne $null -and $FarmDiscoveryFunctionName -ne '')
        { $serverNames = & $FarmDiscoveryFunctionName $PoShMonConfiguration }

    Write-Verbose ("Found the following server(s): " + ($serverNames -join ", "))

    return $serverNames
}