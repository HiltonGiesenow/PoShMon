$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\..\..\') -Resolve
Remove-Module PoShMon -ErrorAction SilentlyContinue
Import-Module (Join-Path $rootPath -ChildPath "PoShMon.psd1")

Describe "New-HtmlBody" {
    InModuleScope PoShMon {

        Mock -CommandName Get-Module -Verifiable -MockWith {
            return @(
                        [pscustomobject]@{
                            Version = "1.2.3"
                        }
            )
        }

        Mock -CommandName Get-PlatformVersion -ModuleName PoShMon -Verifiable -MockWith {
            return @(
                        [pscustomobject]@{
                            Major = "16"
                            Minor = "0"
                            Build = "1234"
                            Revision = "1000"
                        }
            )
        }

        It "Should return a the correct html for given test output" -skip {

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General `
                                -EnvironmentName 'SharePoint' `
                                -PrimaryServerName 'Server1' `
                                -SkipVersionUpdateCheck `
                                -TestsToSkip 'SPServerStatus','WindowsServiceState','SPFailingTimerJobs','SPDatabaseHealth','SPSearchHealth','SPDistributedCacheHealth','WebTests'
                            Notifications -When All {
                                Email -ToAddress "someone@email.com" -FromAddress "all@jones.com" -SmtpServer "smtp.company.com"
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
            $expected = '<head><title></title></head><body style="font-family: verdana; font-size: 12px;"><table width="100%" style="border-collapse: collapse; "><tr><td colspan="3" style="background-color: lightgray">&nbsp;</td></tr><tr><td style="background-color: lightgray">&nbsp;</td><td style="background-color: #1D6097; color: #FFFFFF; Padding: 20px;"><h1>PoShMon Monitoring Report</h1></td><td style="background-color: lightgray">&nbsp;</td></tr><tr><td style="background-color: lightgray">&nbsp;</td><td style="background-color: #000000; color: #FFFFFF; padding: 10px; padding-left: 20px">SharePoint Environment</td><td style="background-color: lightgray">&nbsp;</td></tr><tr><td style="background-color: lightgray">&nbsp;</td><td style="background-color: lightgray; padding-top: 20px;"><div style="width:100%; background-color: #FFFFFF;"><table style="border-collapse: collapse; min-width: 500px; " cellpadding="3"><thead><tr><th align="left" style="border: 1px solid CCCCCC; background-color: #1D6097;" colspan="2"><h2 style="font-size: 16px; color: #FFFFFF">Grouped Test (60.00 Seconds)</h2></th></tr></thead><thead><tr><th align="left" style="border: 1px solid #CCCCCC; background-color: #1D6097; color: #FFFFFF" colspan="2">Server 1</th></tr></thead><tbody><tr><td style="padding-left: 25px">&nbsp;</td><td><table style="border-collapse: collapse;" cellpadding="3"><thead><tr><th align="left" style="border: 1px solid #CCCCCC; background-color: #C7DAE9; color: #126AB0">Message</th><th align="left" style="border: 1px solid #CCCCCC; background-color: #C7DAE9; color: #126AB0">Event ID</th></tr></thead><tbody><tr style=""><td valign="top" style="border: 1px solid #CCCCCC;" align="left">Message 1</td><td valign="top" style="border: 1px solid #CCCCCC;" align="right">123</td></tr><tr style="background-color: #e1e3e8"><td valign="top" style="border: 1px solid #CCCCCC;" align="left">Message 2</td><td valign="top" style="border: 1px solid #CCCCCC;" align="right">456</td></tr></tbody></table></td></tr></tbody><thead><tr><th align="left" style="border: 1px solid #CCCCCC; background-color: #1D6097; color: #FFFFFF" colspan="2">Server 2</th></tr></thead><tbody><tr><td style="padding-left: 25px">&nbsp;</td><td><table style="border-collapse: collapse;" cellpadding="3"><thead><tr><th align="left" style="border: 1px solid #CCCCCC; background-color: #C7DAE9; color: #126AB0">Message</th><th align="left" style="border: 1px solid #CCCCCC; background-color: #C7DAE9; color: #126AB0">Event ID</th></tr></thead><tbody><tr style=""><td valign="top" style="border: 1px solid #CCCCCC;" align="left">Message 3</td><td valign="top" style="border: 1px solid #CCCCCC;" align="right">789</td></tr></tbody></table></td></tr></tbody></table></div><br/><div style="width:100%; background-color: #FFFFFF;"><table style="border-collapse: collapse; min-width: 500px; " cellpadding="3"><thead><tr><th align="left" style="border: 1px solid CCCCCC; background-color: #1D6097;" colspan="2"><h2 style="font-size: 16px; color: #FFFFFF">Ungrouped Test (60.00 Seconds)</h2></th></tr></thead><thead><tr><th align="left" style="border: 1px solid #CCCCCC; background-color: #C7DAE9; color: #126AB0">State</th><th align="left" style="border: 1px solid #CCCCCC; background-color: #C7DAE9; color: #126AB0">Component</th></tr></thead><tbody><tr style=""><td valign="top" style="border: 1px solid #CCCCCC;" align="left">State 1</td><td valign="top" style="border: 1px solid #CCCCCC;" align="right">123</td></tr><tr style="background-color: #e1e3e8"><td valign="top" style="border: 1px solid #CCCCCC;" align="left">State 2</td><td valign="top" style="border: 1px solid #CCCCCC;" align="right">456</td></tr></tbody></table></div><br/></td><td style="background-color: lightgray">&nbsp;</td></tr><tr><td style="background-color: lightgray">&nbsp;</td><td style="background-color: #000000; color: #FFFFFF; padding: 20px"><b>Skipped Tests:</b> SPServerStatus, WindowsServiceState, SPFailingTimerJobs, SPDatabaseHealth, SPSearchHealth, SPDistributedCacheHealth, WebTests<br/><b>Total Elapsed Time (Seconds):</b> 180.00 (3.00 Minutes)</td><td style="background-color: lightgray">&nbsp;</td></tr><tr><td style="background-color: lightgray">&nbsp;</td><td style="background-color: #1D6097; color: #FFFFFF; padding: 20px" align="center">PoShMon Version ' + $currentVersion + ' (version check skipped)</td><td style="background-color: lightgray">&nbsp;</td></tr><tr><td colspan="3" style="background-color: lightgray">&nbsp;</td></tr></table><br/></body>'

            $actual = New-HtmlBody $poShMonConfiguration "All" $testMonitoringOutput $totalElapsedTime

            $actual | Should Be $expected
        }

        It "Should return a the correct html for given test output [if the output structure changes]" {

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General `
                                -EnvironmentName 'SharePoint' `
                                -PrimaryServerName 'Server1' `
                                -SkipVersionUpdateCheck `
                                -TestsToSkip 'SPServerStatus','WindowsServiceState','SPFailingTimerJobs','SPDatabaseHealth','SPSearchHealth','SPDistributedCacheHealth','WebTests'
                            Notifications -When All {
                                Email -ToAddress "someone@email.com" -FromAddress "all@jones.com" -SmtpServer "smtp.company.com"
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

            $expected = '<head><title></title></head><body style="font-family: verdana; font-size: 12px;"><table width="100%" style="border-collapse: collapse; "><tr><td colspan="3" style="background-color: lightgray">&nbsp;</td></tr><tr><td style="background-color: lightgray">&nbsp;</td><td style="background-color: #1D6097; color: #FFFFFF; Padding: 20px;"><h1>PoShMon Monitoring Report</h1></td><td style="background-color: lightgray">&nbsp;</td></tr><tr><td style="background-color: lightgray">&nbsp;</td><td style="background-color: #000000; color: #FFFFFF; padding: 10px; padding-left: 20px">SharePoint Environment</td><td style="background-color: lightgray">&nbsp;</td></tr><tr><td style="background-color: lightgray">&nbsp;</td><td style="background-color: lightgray; padding-top: 20px;"><div style="width:100%; background-color: #FFFFFF;"><table style="border-collapse: collapse; min-width: 500px; " cellpadding="3"><thead><tr><th align="left" style="border: 1px solid CCCCCC; background-color: #1D6097;" colspan="1"><h2 style="font-size: 16px; color: #FFFFFF">Grouped Test (60.00 Seconds)</h2><th align="right" style="border: 1px solid CCCCCC; background-color: #1D6097;"></th></tr></thead><thead><tr><th align="left" style="border: 1px solid #CCCCCC; background-color: #1D6097; color: #FFFFFF" colspan="2">Server 1</th></tr></thead><tbody><tr><td style="padding-left: 25px">&nbsp;</td><td><table style="border-collapse: collapse;" cellpadding="3"><thead><tr><th align="left" style="border: 1px solid #CCCCCC; background-color: #C7DAE9; color: #126AB0">Message</th><th align="left" style="border: 1px solid #CCCCCC; background-color: #C7DAE9; color: #126AB0">Event ID</th></tr></thead><tbody><tr style=""><td valign="top" style="border: 1px solid #CCCCCC;" align="left">Message 1</td><td valign="top" style="border: 1px solid #CCCCCC;" align="right">123</td></tr><tr style="background-color: #e1e3e8"><td valign="top" style="border: 1px solid #CCCCCC;" align="left">Message 2</td><td valign="top" style="border: 1px solid #CCCCCC;" align="right">456</td></tr></tbody></table></td></tr></tbody><thead><tr><th align="left" style="border: 1px solid #CCCCCC; background-color: #1D6097; color: #FFFFFF" colspan="2">Server 2</th></tr></thead><tbody><tr><td style="padding-left: 25px">&nbsp;</td><td><table style="border-collapse: collapse;" cellpadding="3"><thead><tr><th align="left" style="border: 1px solid #CCCCCC; background-color: #C7DAE9; color: #126AB0">Message</th><th align="left" style="border: 1px solid #CCCCCC; background-color: #C7DAE9; color: #126AB0">Event ID</th></tr></thead><tbody><tr style=""><td valign="top" style="border: 1px solid #CCCCCC;" align="left">Message 3</td><td valign="top" style="border: 1px solid #CCCCCC;" align="right">789</td></tr></tbody></table></td></tr></tbody></table></div><br/><div style="width:100%; background-color: #FFFFFF;"><table style="border-collapse: collapse; min-width: 500px; " cellpadding="3"><thead><tr><th align="left" style="border: 1px solid CCCCCC; background-color: #1D6097;" colspan="1"><h2 style="font-size: 16px; color: #FFFFFF">Ungrouped Test (60.00 Seconds)</h2><th align="right" style="border: 1px solid CCCCCC; background-color: #1D6097;"></th></tr></thead><thead><tr><th align="left" style="border: 1px solid #CCCCCC; background-color: #C7DAE9; color: #126AB0">State</th><th align="left" style="border: 1px solid #CCCCCC; background-color: #C7DAE9; color: #126AB0">Component</th></tr></thead><tbody><tr style=""><td valign="top" style="border: 1px solid #CCCCCC;" align="left">State 1</td><td valign="top" style="border: 1px solid #CCCCCC;" align="right">123</td></tr><tr style="background-color: #e1e3e8"><td valign="top" style="border: 1px solid #CCCCCC;" align="left">State 2</td><td valign="top" style="border: 1px solid #CCCCCC;" align="right">456</td></tr></tbody></table></div><br/></td><td style="background-color: lightgray">&nbsp;</td></tr><tr><td style="background-color: lightgray">&nbsp;</td><td style="background-color: #000000; color: #FFFFFF; padding: 20px"><b>Skipped Tests:</b> SPServerStatus, WindowsServiceState, SPFailingTimerJobs, SPDatabaseHealth, SPSearchHealth, SPDistributedCacheHealth, WebTests<br/><b>Total Elapsed Time (Seconds):</b> 180.00 (3.00 Minutes)</td><td style="background-color: lightgray">&nbsp;</td></tr><tr><td style="background-color: lightgray">&nbsp;</td><td style="background-color: #1D6097; color: #FFFFFF; padding: 20px" align="center">PoShMon Version 1.2.3 (version check skipped)</td><td style="background-color: lightgray">&nbsp;</td></tr><tr><td colspan="3" style="background-color: lightgray">&nbsp;</td></tr></table><br/></body>'

            $actual = New-HtmlBody $poShMonConfiguration "All" $testMonitoringOutput $totalElapsedTime

            $actual | Should Be $expected
        }

        It "Should return a the correct html if an exception occurs in a test" {

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General `
                                -EnvironmentName 'SharePoint' `
                                -PrimaryServerName 'Server1' `
                                -SkipVersionUpdateCheck `
                                -TestsToSkip 'SPServerStatus','WindowsServiceState','SPFailingTimerJobs','SPDatabaseHealth','SPSearchHealth','SPDistributedCacheHealth','WebTests'
                            Notifications -When OnlyOnFailure {
                                Email -ToAddress "someone@email.com" -FromAddress "all@jones.com" -SmtpServer "smtp.company.com"
                            }
                        }

            $testMonitoringOutput = @(
                @{
                    "SectionHeader" = "Test1"
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
                },
                @{
                    "SectionHeader" = "Test2 - Failed"
                    "NoIssuesFound" = $false
                    "Exception" = [Exception]::new("Something went wrong")
                }
            )

            $now = Get-Date
            $totalElapsedTime = $now.Subtract($now.AddMinutes(-3))

            $expected = '<head><title></title></head><body style="font-family: verdana; font-size: 12px;"><table width="100%" style="border-collapse: collapse; "><tr><td colspan="3" style="background-color: lightgray">&nbsp;</td></tr><tr><td style="background-color: lightgray">&nbsp;</td><td style="background-color: #1D6097; color: #FFFFFF; Padding: 20px;"><h1>PoShMon Monitoring Report</h1></td><td style="background-color: lightgray">&nbsp;</td></tr><tr><td style="background-color: lightgray">&nbsp;</td><td style="background-color: #000000; color: #FFFFFF; padding: 10px; padding-left: 20px">SharePoint Environment</td><td style="background-color: lightgray">&nbsp;</td></tr><tr><td style="background-color: lightgray">&nbsp;</td><td style="background-color: lightgray; padding-top: 20px;"><div style="width:100%; background-color: #FFFFFF;"><table style="border-collapse: collapse; min-width: 500px; " cellpadding="3"><thead><tr><th align="left" style="border: 1px solid CCCCCC; background-color: #1D6097;" colspan="1"><h2 style="font-size: 16px; color: #FFFFFF">Test1 (60.00 Seconds)</h2><th align="right" style="border: 1px solid CCCCCC; background-color: #1D6097;"></th></tr></thead><thead><tr><th align="left" style="border: 1px solid #CCCCCC; background-color: #C7DAE9; color: #126AB0">State</th><th align="left" style="border: 1px solid #CCCCCC; background-color: #C7DAE9; color: #126AB0">Component</th></tr></thead><tbody><tr style=""><td valign="top" style="border: 1px solid #CCCCCC;" align="left">State 1</td><td valign="top" style="border: 1px solid #CCCCCC;" align="right">123</td></tr><tr style="background-color: #e1e3e8"><td valign="top" style="border: 1px solid #CCCCCC;" align="left">State 2</td><td valign="top" style="border: 1px solid #CCCCCC;" align="right">456</td></tr></tbody></table></div><br/><div style="width:100%; background-color: #FFFFFF;"><table style="border-collapse: collapse; min-width: 500px; " cellpadding="3"><thead><tr><th align="left" style="border: 1px solid CCCCCC; background-color: #1D6097;" colspan="-1"><h2 style="font-size: 16px; color: #FFFFFF">Test2 - Failed</h2><th align="right" style="border: 1px solid CCCCCC; background-color: #1D6097;"></th></tr></thead><tbody><tr><td style="background-color: #FCCFC5">An Exception Occurred: System.Exception: Something went wrong</td></tr></tbody></table></div><br/></td><td style="background-color: lightgray">&nbsp;</td></tr><tr><td style="background-color: lightgray">&nbsp;</td><td style="background-color: #000000; color: #FFFFFF; padding: 20px"><b>Skipped Tests:</b> SPServerStatus, WindowsServiceState, SPFailingTimerJobs, SPDatabaseHealth, SPSearchHealth, SPDistributedCacheHealth, WebTests<br/><b>Total Elapsed Time (Seconds):</b> 180.00 (3.00 Minutes)</td><td style="background-color: lightgray">&nbsp;</td></tr><tr><td style="background-color: lightgray">&nbsp;</td><td style="background-color: #1D6097; color: #FFFFFF; padding: 20px" align="center">PoShMon Version 1.2.3 (version check skipped)</td><td style="background-color: lightgray">&nbsp;</td></tr><tr><td colspan="3" style="background-color: lightgray">&nbsp;</td></tr></table><br/></body>'

            $actual = New-HtmlBody $poShMonConfiguration "All" $testMonitoringOutput $totalElapsedTime

            $actual | Should Be $expected
        }

    }
}