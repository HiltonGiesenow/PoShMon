$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\..\') -Resolve
Remove-Module PoShMon -ErrorAction SilentlyContinue
Import-Module (Join-Path $rootPath -ChildPath "PoShMon.psd1")

Describe "New-EmailBody" {
    It "Should return a the correct html for given test output" {

        $poShMonConfiguration = New-PoShMonConfiguration {
                        General `
                            -EnvironmentName 'SharePoint' `
                            -TestsToSkip 'SPServerStatus','WindowsServiceState','SPFailingTimerJobs','SPDatabaseHealth','SPSearchHealth','SPDistributedCacheHealth','WebTests'
                        Notifications -When All {
                            Email -ToAddress "hilton@giesenow.com" -FromAddress "all@jones.com" -SmtpServer "smtp.company.com"
                        }
                    }

        $testMonitoringOutput = @(
            @{
                "SectionHeader" = "Grouped Test"
                "OutputHeaders" = @{ 'EventID' = 'Event ID'; 'Message' ='Message' }
                "NoIssuesFound" = $true
                "ElapsedTime" = (Get-Date).Subtract((Get-Date).AddMinutes(-1))
                "OutputValues" = @(
                                    @{
                                        "GroupName" = "Server 1"
                                        "GroupOutputValues" = @(
                                            @{
                                                "EventID" = 123
                                                "Message" = "Message 1"
                                            },
                                            @{
                                                "EventID" = 456
                                                "Message" = "Message 2"
                                            }
                                        )
                                    },
                                    @{
                                        "GroupName" = "Server 2"
                                        "GroupOutputValues" = @(
                                            @{
                                                "EventID" = 789
                                                "Message" = "Message 3"
                                            }
                                        )
                                    }
                                )
            }
            @{
                "SectionHeader" = "Ungrouped Test"
                "OutputHeaders" = @{ 'ComponentName' = 'Component'; 'State' = 'State' }
                "NoIssuesFound" = $false
                "ElapsedTime" = (Get-Date).Subtract((Get-Date).AddMinutes(-1))
                "OutputValues" = @(
                                    @{
                                        "ComponentName" = 123
                                        "State" = "State 1"
                                    },
                                    @{
                                        "ComponentName" = 456
                                        "State" = "State 2"
                                    }
                                )
            }
        )

        $totalElapsedTime = (Get-Date).Subtract((Get-Date).AddMinutes(-3))

        $currentVersion = (Get-Module PoShmon).Version.ToString()
        $expected = '<head><title>SharePoint Monitoring Report</title></head><body><h1>SharePoint Monitoring Report</h1><p><h1>Grouped Test (60.00 Seconds)</h1><table border="1"><thead><tr><th align="left" colspan="2"><h2>Server 1</h2></th></tr><tr><th align="left">Message</th><th align="left">Event ID</th></tr></thead><tbody><tr><td valign="top" align="left">Message 1</td><td valign="top" align="right">123</td></tr><tr><td valign="top" align="left">Message 2</td><td valign="top" align="right">456</td></tr></tbody><thead><tr><th align="left" colspan="2"><h2>Server 2</h2></th></tr><tr><th align="left">Message</th><th align="left">Event ID</th></tr></thead><tbody><tr><td valign="top" align="left">Message 3</td><td valign="top" align="right">789</td></tr></tbody></table><p><h1>Ungrouped Test (60.00 Seconds)</h1><table border="1"><thead><tr><th align="left">State</th><th align="left">Component</th></tr></thead><tbody><tr><td valign="top" align="left">State 1</td><td valign="top" align="right">123</td></tr><tr><td valign="top" align="left">State 2</td><td valign="top" align="right">456</td></tr></tbody></table><p>Skipped Tests: SPServerStatus, WindowsServiceState, SPFailingTimerJobs, SPDatabaseHealth, SPSearchHealth, SPDistributedCacheHealth, WebTests</p><p>Total Elapsed Time (Seconds): 180.00 (3.00 Minutes)</p><p>PoShMon Version: ' + $currentVersion + '</p></body>'

        $actual = New-EmailBody $poShMonConfiguration "All" $testMonitoringOutput $totalElapsedTime -Verbose

        $actual | Should Be $expected
    }

    It "Should return a the correct html for given test output [if the output structure changes]" -Skip {

        $poShMonConfiguration = New-PoShMonConfiguration {
                        General `
                            -EnvironmentName 'SharePoint' `
                            -TestsToSkip 'SPServerStatus','WindowsServiceState','SPFailingTimerJobs','SPDatabaseHealth','SPSearchHealth','SPDistributedCacheHealth','WebTests'
                        Notifications -When All {
                            Email -ToAddress "hilton@giesenow.com" -FromAddress "all@jones.com" -SmtpServer "smtp.company.com"
                        }
                    }

        $testMonitoringOutput = @(
            @{
                "SectionHeader" = "Grouped Test"
                "OutputHeaders" = @{ 'EventID' = 'Event ID'; 'Message' ='Message' }
                "NoIssuesFound" = $true
                "ElapsedTime" = (Get-Date).Subtract((Get-Date).AddMinutes(-1))
                "GroupBy" = "Server"
                "OutputValues" = @(
                                    [PSCustomObject]@{
                                        "EventID" = 123
                                        "Message" = "Message 1"
                                        "Server" = "Server 1"
                                    },
                                    [PSCustomObject]@{
                                        "EventID" = 456
                                        "Message" = "Message 2"
                                        "Server" = "Server 1"
                                    },
                                    [PSCustomObject]@{
                                        "EventID" = 789
                                        "Message" = "Message 3"
                                        "Server" = "Server 2"
                                    }
                                )
            }
            @{
                "SectionHeader" = "Ungrouped Test"
                "OutputHeaders" = @{ 'ComponentName' = 'Component'; 'State' = 'State' }
                "NoIssuesFound" = $false
                "ElapsedTime" = (Get-Date).Subtract((Get-Date).AddMinutes(-1))
                "OutputValues" = @(
                                    [PSCustomObject]@{
                                        "ComponentName" = 123
                                        "State" = "State 1"
                                    },
                                    [PSCustomObject]@{
                                        "ComponentName" = 456
                                        "State" = "State 2"
                                    }
                                )
            }
        )

        $totalElapsedTime = (Get-Date).Subtract((Get-Date).AddMinutes(-3))

        $currentVersion = (Get-Module PoShmon).Version.ToString()
        $expected = '<head><title>SharePoint Monitoring Report</title></head><body><h1>SharePoint Monitoring Report</h1><p><h1>Grouped Test (60.00 Seconds)</h1><table border="1"><thead><tr><th align="left" colspan="2"><h2>Server 1</h2></th></tr><tr><th align="left">Message</th><th align="left">Event ID</th></tr></thead><tbody><tr><td valign="top" align="left">Message 1</td><td valign="top" align="right">123</td></tr><tr><td valign="top" align="left">Message 2</td><td valign="top" align="right">456</td></tr></tbody><thead><tr><th align="left" colspan="2"><h2>Server 2</h2></th></tr><tr><th align="left">Message</th><th align="left">Event ID</th></tr></thead><tbody><tr><td valign="top" align="left">Message 3</td><td valign="top" align="right">789</td></tr></tbody></table><p><h1>Ungrouped Test (60.00 Seconds)</h1><table border="1"><thead><tr><th align="left">State</th><th align="left">Component</th></tr></thead><tbody><tr><td valign="top" align="left">State 1</td><td valign="top" align="right">123</td></tr><tr><td valign="top" align="left">State 2</td><td valign="top" align="right">456</td></tr></tbody></table><p>Skipped Tests: SPServerStatus, WindowsServiceState, SPFailingTimerJobs, SPDatabaseHealth, SPSearchHealth, SPDistributedCacheHealth, WebTests</p><p>Total Elapsed Time (Seconds): 180.00 (3.00 Minutes)</p><p>PoShMon Version: ' + $currentVersion + '</p></body>'

        $actual = New-EmailBody $poShMonConfiguration "All" $testMonitoringOutput $totalElapsedTime -Verbose

        $actual | Should Be $expected
    }

    It "Should return a the correct html if an exception occurs in a test" {

        $poShMonConfiguration = New-PoShMonConfiguration {
                        General `
                            -EnvironmentName 'SharePoint' `
                            -TestsToSkip 'SPServerStatus','WindowsServiceState','SPFailingTimerJobs','SPDatabaseHealth','SPSearchHealth','SPDistributedCacheHealth','WebTests'
                        Notifications -When OnlyOnFailure {
                            Email -ToAddress "hilton@giesenow.com" -FromAddress "all@jones.com" -SmtpServer "smtp.company.com"
                        }
                    }

        $testMonitoringOutput = @(
            @{
                "SectionHeader" = "Test1"
                "OutputHeaders" = @{ 'ComponentName' = 'Component'; 'State' = 'State' }
                "NoIssuesFound" = $false
                "ElapsedTime" = (Get-Date).Subtract((Get-Date).AddMinutes(-1))
                "OutputValues" = @(
                                    @{
                                        "ComponentName" = 123
                                        "State" = "State 1"
                                    },
                                    @{
                                        "ComponentName" = 456
                                        "State" = "State 2"
                                    }
                                )
            },
            @{
                "SectionHeader" = "Test2 - Failed"
                "NoIssuesFound" = $false
                "Exception" = [Exception]::new("Something went wrong")
            }
        )

        $totalElapsedTime = (Get-Date).Subtract((Get-Date).AddMinutes(-3))

        $currentVersion = (Get-Module PoShmon).Version.ToString()
        $expected = '<head><title>SharePoint Monitoring Report</title></head><body><h1>SharePoint Monitoring Report</h1><p><h1>Test1 (60.00 Seconds)</h1><table border="1"><thead><tr><th align="left">State</th><th align="left">Component</th></tr></thead><tbody><tr><td valign="top" align="left">State 1</td><td valign="top" align="right">123</td></tr><tr><td valign="top" align="left">State 2</td><td valign="top" align="right">456</td></tr></tbody></table><p><h1>Test2 - Failed</h1><table border="1"><tbody><tr><td>An Exception Occurred</td></tr><tr><td>System.Exception: Something went wrong</td></tr></tbody</table><p>Skipped Tests: SPServerStatus, WindowsServiceState, SPFailingTimerJobs, SPDatabaseHealth, SPSearchHealth, SPDistributedCacheHealth, WebTests</p><p>Total Elapsed Time (Seconds): 180.00 (3.00 Minutes)</p><p>PoShMon Version: ' + $currentVersion + '</p></body>'

        $actual = New-EmailBody $poShMonConfiguration "All" $testMonitoringOutput $totalElapsedTime -Verbose

        $actual | Should Be $expected
    }


}