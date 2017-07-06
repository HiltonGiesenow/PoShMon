Function Invoke-OperationVerificationFrameworkScan
{
    [CmdletBinding()]
    Param(
        [hashtable]$PoShMonConfiguration,
        [hashtable]$OperationValidationFrameworkNotificationSink,
        [System.Collections.ArrayList]$TestOutputValues,
        [bool]$Critical
    )

    foreach ($outputSection in $TestOutputValues)
    {
    
        $issueFound = $false

        Describe $outputSection.SectionHeader {
            It "Should not have any Exceptions" {
                $outputSection.ContainsKey("Exception") | Should Be $false
            }

            foreach ($outputValue in $outputSection.OutputValues)
            {
                foreach ($headerKey in $outputSection.OutputHeaders.Keys)
                {
                    $fieldValue = $outputValue.psobject.Properties[$headerKey].Value

                    It "Should not find any issues" {
                        if ($outputValue.psobject.Properties['Highlight'].Value -ne $null -and $outputValue.psobject.Properties['Highlight'].Value.Contains($headerKey))
                        {
                            $issueFound = $true

                            $fieldValue | Should Not Be $fieldValue
                        } else {
                            $fieldValue | Should Be $fieldValue
                        }
                    }
                }
            }

            # check now if an issue was found, but not in one of the items - it may be a test where the 
            # existence of items is itself the failure, like checking an error log
            if ($issueFound -eq $false -and $outputSection.NoIssuesFound -eq $false)
            {
                It "Should find no issues" {
                    $outputSection.OutputValues.Count | Should Be 0
                }
            }
        }
    }

 }