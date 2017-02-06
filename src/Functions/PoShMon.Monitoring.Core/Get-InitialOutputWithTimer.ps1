Function Get-InitialOutputWithTimer
{
    [CmdletBinding()]
    param (
        [string]$SectionHeader,
        [System.Collections.Specialized.OrderedDictionary]$OutputHeaders
    )

    $initialOutput = Get-InitialOutput @PSBoundParameters

    $initialOutput.StopWatch = [System.Diagnostics.Stopwatch]::StartNew()

    return $initialOutput
}