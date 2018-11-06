Function Get-InitialOutput
{
    [CmdletBinding()]
    param (
        [string]$SectionHeader,
        [string]$GroupBy = $null,
        [System.Collections.Specialized.OrderedDictionary]$OutputHeaders,
        [string]$HeaderUrl = $null,
        [string]$LinkColumn = $null
    )

    Write-Verbose "Initiating '$SectionHeader' Test..."

    $initialOutput = @{
                        "SectionHeader" = $sectionHeader;
                        "NoIssuesFound" = $true;
                        "OutputHeaders" = $OutputHeaders;
                        "OutputValues" = @();
                        }

    if ($GroupBy -ne $null -and $GroupBy -ne '')
        { $initialOutput.GroupBy = $GroupBy }

    if ($HeaderUrl -ne $null -and $HeaderUrl -ne '')
        { $initialOutput.HeaderUrl = $HeaderUrl }

    if ($LinkColumn -ne $null -and $LinkColumn -ne '')
        { $initialOutput.LinkColumn = $LinkColumn }

    return $initialOutput
}