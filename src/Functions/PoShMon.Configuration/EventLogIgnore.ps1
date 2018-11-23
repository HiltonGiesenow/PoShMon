Function New-EventLogIgnore
{
    [CmdletBinding()]
    param(
        [parameter(Mandatory)]
        [int]$EventID,
        [parameter(HelpMessage="If you want to ignore all all instances of this event Id, leave this at 0 (default), but if you want to only ignore up to a threshold (i.e. ignore the first x amount occurring, but notify if more than x occur), then set this to your desired threshold")]
        [int]$IgnoreIfLessThan = 0
    )

    return @{
        TypeName = 'PoShMon.ConfigurationItems.OperatingSystem.EventLogIgnore'
        EventID = $EventID
        IgnoreIfLessThan = $IgnoreIfLessThan
    }
}