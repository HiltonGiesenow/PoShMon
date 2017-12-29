$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\..\..\') -Resolve
Remove-Module PoShMon -ErrorAction SilentlyContinue
Import-Module (Join-Path $rootPath -ChildPath "PoShMon.psd1")

Describe "Initialize-Notifications" {
    It "Should return a the correct html for given test output" -Skip {

        <#$poShMonConfiguration = @{
                                    TypeName = 'PoShMon.Configuration'
                                    General = @{
                                                TypeName = "PoShMon.ConfigurationItems.General"
                                                EnvironmentName = "SharePoint"
                                                TestsToSkip = 'SkippedTest1','SkippedTest2'
                                            }
                                    Notifications = @(
                                        @{
                                            TypeName = "PoShMon.ConfigurationItems.NotificationCollection-All"
                                            Sinks = @{
                                                        TypeName = 'PoShMon.ConfigurationItems.Notifications.Email'
                                                        ToAddress = "testTo@email.com"
                                                        FromAddress = "testFrom@email.com"
                                                    }
                                            When = "All"
                                        }
                                    )
                                }#>

        Mock -CommandName Send-MailMessage -Verifiable -MockWith {
            return
        }

        $poShMonConfiguration = New-PoShMonConfiguration {
                                    General -EnvironmentName "SharePoint" -PrimaryServerName "Server1" -TestsToSkip 'SkippedTest1','SkippedTest2'
                                    Notifications -When All {
                                        Email -ToAddress "testTo@email.com" -FromAddress "testFrom@email.com" -SmtpServer "EXCHANGE.COMPANY.COM"
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
                                        "Component" = 123
                                        "State" = "State 1"
                                    },
                                    @{
                                        "Component" = 456
                                        "State" = "State 2"
                                    }
                                )
            }
        )

        $totalElapsedTime = (Get-Date).Subtract((Get-Date).AddMinutes(-5))

        $actual = Initialize-Notifications $poShMonConfiguration $testMonitoringOutput $totalElapsedTime -Verbose

    }
}
