Function Get-InitialOutput
{
    [CmdletBinding()]
    param (
        [string]$SectionHeader,
        [string]$GroupBy = $null,
        [System.Collections.Specialized.OrderedDictionary]$OutputHeaders
    )

    Write-Verbose "Initiating '$SectionHeader' Test..."

    $initialOutput =  @{
                        "SectionHeader" = $sectionHeader;
                        "NoIssuesFound" = $true;
                        "OutputHeaders" = $OutputHeaders;
                        "OutputValues" = @();
                        }

    if ($GroupBy -ne $null -and $GroupBy -ne '')
        { $initialOutput.GroupBy = $GroupBy }

    return $initialOutput
}