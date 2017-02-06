Function Add-Scripts
{
    [CmdletBinding()]
    Param(
        [string[]]$RepairScripts
    )

    $scriptsLoaded = @()

    Foreach($scriptToImport in $RepairScripts)
    {
        if (Test-Path $scriptToImport)
        {
            . $scriptToImport
            $scriptsLoaded += $scriptToImport | Get-Item | Select -ExpandProperty BaseName
        } else {
            Write-Warning "Script not found, will be skipped: $scriptToImport"
        }
    }

    return $scriptsLoaded
}