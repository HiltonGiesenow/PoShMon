Function Import-RepairScripts
{
    [CmdletBinding()]
    Param(
        [string[]]$RepairScripts
    )

    Begin
    {
        $repairFunctionNames = @()
    }

    Process
    {
        foreach ($repairScript in $RepairScripts)
        {
            if (Test-Path $repairScript)
            {
                . $repairScript # Load the script

                $repairFunctionName = $repairScript | Get-Item | Select -ExpandProperty BaseName

                $repairFunctionNames += $repairFunctionName

            } else {
                Write-Warning "Script not found, will be skipped: $scriptToImport"
            }
        }
    }
    
    End
    {
        return $repairFunctionNames
    }
}