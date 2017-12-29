Function Invoke-OperationValidationFrameworkScan
{
    [CmdletBinding()]
    Param(
		[hashtable]$PoShMonConfiguration,
		[System.Collections.ArrayList]$TestOutputValues,
		[hashtable]$NotificationSink,
		[ValidateSet("All","OnlyOnFailure","None")][string]$SendNotificationsWhen,
		[TimeSpan]$TotalElapsedTime,
        [bool]$Critical
    )

    foreach ($outputSection in $TestOutputValues)
    {
    
        Describe $outputSection.SectionHeader {
            It "Should not have any Exceptions" {
                $outputSection.ContainsKey("Exception") | Should Be $false
            }


            $isAnItemError = $false

            # Some errors occur -within- the item, e.g. harddrive space below a minimum threshold.
            # In other tests, the actual presence of values in the output is the error itself, e.g. if items are found in an error log.
            # The code below checks for that
            if ($outputSection.NoIssuesFound -eq $false) {
                foreach ($outputValue in $outputSection.OutputValues)
                {
                    $highlight = $outputValue.psobject.Properties['Highlight'].Value
                    if ($highlight -ne $null -and $highlight.Count -gt 0)
                    {
                        $isAnItemError = $true
                    }
                }
            }   

            if ($outputSection.NoIssuesFound -eq $false -and $isAnItemError -eq $false)
            {
                It "Should find no items for '$($outputSection.SectionHeader)'" {
                    $outputSection.OutputValues.Count | Should Be 0
                }

                if ($outputSection.OutputValues.Count -gt 0)
                {
                    foreach ($outputValue in $outputSection.OutputValues)
                    {
                        It "The following items exist: " {
                            $actualJsonValue = ConvertTo-Json($outputValue)
                            $actualJsonValue | Should Not Be $actualJsonValue
                        }
                    }
                }
            } else {
                foreach ($outputValue in $outputSection.OutputValues)
                {
                    #$cleanObject = $outputValue.psobject.Copy()
                    #$cleanObject.psobject.Properties.Remove("Highlight")
                    #$cleanJsonValue = ConvertTo-Json($cleanObject)
                    $actualJsonValue = ConvertTo-Json($outputValue)
                    
                    foreach ($headerKey in $outputSection.OutputHeaders.Keys)
                    {
                        $fieldValue = $outputValue.psobject.Properties[$headerKey].Value

                        It "Should not find any issues" {
                            if ($outputValue.psobject.Properties['Highlight'].Value -ne $null -and $outputValue.psobject.Properties['Highlight'].Value.Contains($headerKey))
                            {
                                $global:issueFound = $true

                                $actualJsonValue | Should Not Be $actualJsonValue
                            } else {
                                $actualJsonValue | Should Be $actualJsonValue
                            }
                        }
                    }
                }
            }

            # check now if an issue was found, but not in one of the items - it may be a test where the 
            # existence of items is itself the failure, like checking an error log
            #if ($global:issueFound -eq $false -and $outputSection.NoIssuesFound -eq $false)
            #{

           # }
        }
    }

 }