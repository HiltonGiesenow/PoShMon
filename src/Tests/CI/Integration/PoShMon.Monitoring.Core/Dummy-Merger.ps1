Function Dummy-Merger
{
    [CmdletBinding()]
    Param(
        [hashtable]$PoShMonConfiguration,
        [System.Collections.ArrayList]$TestOutputValues
    )

    $TestOutputValues.Remove(($TestOutputValues | Where SectionHeader -eq "SPServerStatus Mock"))
    $TestOutputValues.Remove(($TestOutputValues | Where SectionHeader -eq "CPULoad Mock"))
    
    $newOutput = @{
                        "SectionHeader" = "New Merger Mock"
                        "OutputHeaders" = @{ 'MergeItem1' = 'Merge Item 1'; }
                        "NoIssuesFound" = $true
                        "ElapsedTime" = (Get-Date).Subtract((Get-Date).AddMinutes(-1))
                        "OutputValues" = @(
                                            [PSCustomObject]@{
                                                "MergeItem1" = 123
                                                "Value" = "The Value"
                                            }
                                        )
                    }

    $TestOutputValues.Insert(0, $newOutput)

    #return $TestOutputValues
}