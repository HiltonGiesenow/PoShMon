Function Dummy-Test
{
    [CmdletBinding()]
    Param(
        [hashtable]$PoShMonConfiguration
    )

    return @{
        "SectionHeader" = "Dummy Test Section"
        "OutputHeaders" = @{ 'ThingID' = 'Thing ID'; 'Message' = 'Message'; 'Server' = 'Server' }
        "NoIssuesFound" = $true
        "ElapsedTime" = (Get-Date).Subtract((Get-Date).AddMinutes(-1))
        "GroupBy" = "Server"
        "OutputValues" = @(
                            [PSCustomObject]@{
                                "ThingID" = 123
                                "Message" = "Message 1"
                                "Server" = "Server 1"
                            },
                            [PSCustomObject]@{
                                "ThingID" = 456
                                "Message" = "Message 2"
                                "Server" = "Server 1"
                            },
                            [PSCustomObject]@{
                                "ThingID" = 789
                                "Message" = "Message 3"
                                "Server" = "Server 2"
                            }
                        )
    }
}