Function Get-InitialOutput
{
    [CmdletBinding()]
    param (
        [string]$SectionHeader,
        [System.Collections.Specialized.OrderedDictionary]$OutputHeaders
    )

    Write-Verbose "Initiating '$($mainOutput.SectionHeader)'..."

    return @{
        "SectionHeader" = $sectionHeader;
        "NoIssuesFound" = $true;
        "OutputHeaders" = $OutputHeaders;
        "OutputValues" = @();
        }
}