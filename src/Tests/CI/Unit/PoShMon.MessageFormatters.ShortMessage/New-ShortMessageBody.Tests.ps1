$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\..\..\') -Resolve
Remove-Module PoShMon -ErrorAction SilentlyContinue
Import-Module (Join-Path $rootPath -ChildPath "PoShMon.psd1")

Describe "New-ShortMessageBody" {
    InModuleScope PoShMon {

        It "Should return a the correct output for given test output" {

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General `
                                -EnvironmentName 'SharePoint' `
                                -PrimaryServerName 'Server1' `
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
            $expected = "Grouped Test : issue(s) found - No `r`nUngrouped Test : issue(s) found - Yes `r`n"

            $actual = New-ShortMessageBody $poShMonConfiguration "All" $testMonitoringOutput $totalElapsedTime -Verbose

            $actual | Should Be $expected
        }

        It "Should return a the correct output if an exception occurs in a test" {

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General `
                                -EnvironmentName 'SharePoint' `
                                -PrimaryServerName 'Server1' `
                                -TestsToSkip 'SPServerStatus','WindowsServiceState','SPFailingTimerJobs','SPDatabaseHealth','SPSearchHealth','SPDistributedCacheHealth','WebTests'
                            Notifications -When OnlyOnFailure {
                                Email -ToAddress "someone@email.com" -FromAddress "all@jones.com" -SmtpServer "smtp.company.com"
                            }
                        }

            $testMonitoringOutput = @(
                @{
                    "SectionHeader" = "Test1"
                    "OutputHeaders" = @{ 'ComponentName' = 'Component'; 'State' = 'State' }
                    "NoIssuesFound" = $true
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
            $expected = "Test1 : issue(s) found - No `r`nTest2 - Failed : issue(s) found - Yes (Exception occurred) `r`n"

            $actual = New-ShortMessageBody $poShMonConfiguration "All" $testMonitoringOutput $totalElapsedTime -Verbose

            $actual | Should Be $expected
        }

    }
}