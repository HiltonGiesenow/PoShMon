Function Get-InitialOutput
{
    [CmdletBinding()]
    param (
        [string]$SectionHeader,
        [System.Collections.Specialized.OrderedDictionary]$OutputHeaders
    )

    Write-Verbose "Initiating '$SectionHeader' Test..."

    return @{
        "SectionHeader" = $sectionHeader;
        "NoIssuesFound" = $true;
        "OutputHeaders" = $OutputHeaders;
        "OutputValues" = @();
        }
}