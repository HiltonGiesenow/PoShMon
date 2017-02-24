Function Get-InitialOutputWithTimer
{
    [CmdletBinding()]
    param (
        [string]$SectionHeader,
        [string]$GroupBy = $null,
        [System.Collections.Specialized.OrderedDictionary]$OutputHeaders,
        [string]$HeaderUrl = $null,
        [string]$LinkColumn = $null
    )

    $initialOutput = Get-InitialOutput @PSBoundParameters

    $initialOutput.StopWatch = [System.Diagnostics.Stopwatch]::StartNew()

    return $initialOutput
}