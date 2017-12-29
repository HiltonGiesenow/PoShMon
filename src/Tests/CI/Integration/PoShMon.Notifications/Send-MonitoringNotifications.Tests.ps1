$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\..\..\') -Resolve
Remove-Module PoShMon -ErrorAction SilentlyContinue
Import-Module (Join-Path $rootPath -ChildPath "PoShMon.psd1")

$o365TeamsConfigPath = [Environment]::GetFolderPath("MyDocuments") + "\o365TeamsConfig.json"

Describe "Send-MonitoringNotifications" {
    InModuleScope PoShMon {

        #Mock -CommandName Get-Module -Verifiable -MockWith {
        #    return @(
        ##                [pscustomobject]@{
        #                    Version = "1.2.3"
        #                }
        #            )
        #}

        It "Should send notifications to the specified channels (email, Pushbullet, O365 Teams)" {

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General `
                                -EnvironmentName 'SharePoint' `
                                -MinutesToScanHistory 60 `
                                -PrimaryServerName 'APPServer1' `
                                -ConfigurationName SpFarmPosh `
                                -SkipVersionUpdateCheck `
                                -TestsToSkip 'SPServerStatus','WindowsServiceState','SPFailingTimerJobs','SPDatabaseHealth','SPSearchHealth','SPDistributedCacheHealth','WebTests'
                            Notifications -When All {
                                Email -ToAddress "hilton@email.com" -FromAddress "all@jones.com" -SmtpServer "smtp.company.com"
                                Pushbullet -AccessToken "TestAccessToken" -DeviceId "TestDeviceID"
                                O365Teams -TeamsWebHookUrl "http://teams.office.com/theapi"
                            }
                        }

            $testMonitoringOutput = @(
                @{
                    "SectionHeader" = "Grouped Test With A Long Name"
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

            $totalElapsedTime = (Get-Date).Subtract((Get-Date).AddMinutes(-3))

            Mock -CommandName Send-EmailMonitoringMessage -ModuleName PoShMon -Verifiable -MockWith {
                return
            }
            Mock -CommandName Send-PushbulletMonitoringMessage -ModuleName PoShMon -Verifiable -MockWith {
                return
            }
            Mock -CommandName Send-O365TeamsMonitoringMessage -ModuleName PoShMon -Verifiable -MockWith {
                return
            }

            $actual = Send-MonitoringNotifications $poShMonConfiguration $poShMonConfiguration.Notifications.Sinks "All" $testMonitoringOutput $totalElapsedTime

            Assert-VerifiableMock
        }

        It "Should mark failures as Critical" {

            #$o365TeamsConfig = Get-Content -Raw -Path $o365TeamsConfigPath | ConvertFrom-Json

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General `
                                -EnvironmentName 'SharePoint' `
                                -MinutesToScanHistory 60 `
                                -PrimaryServerName 'APPServer1' `
                                -ConfigurationName SpFarmPosh `
                                -SkipVersionUpdateCheck `
                                -TestsToSkip 'SPServerStatus','WindowsServiceState','SPFailingTimerJobs','SPDatabaseHealth','SPSearchHealth','SPDistributedCacheHealth','WebTests'
                            Notifications -When OnlyOnFailure {
                                Email -ToAddress "hilton@email.com" -FromAddress "all@jones.com" -SmtpServer "smtp.company.com"
                                Pushbullet -AccessToken "TestAccessToken" -DeviceId "TestDeviceID"
                            }
                        }

            $testMonitoringOutput = @(
                @{
                    "SectionHeader" = "Grouped Test With A Long Name"
                    "OutputHeaders" = @{ 'EventID' = 'Event ID'; 'Message' ='Message' }
                    "NoIssuesFound" = $false
                    "ElapsedTime" = (Get-Date).Subtract((Get-Date).AddMinutes(-1))
                    "OutputValues" = @()
                }
                @{
                    "SectionHeader" = "Ungrouped Test"
                    "OutputHeaders" = @{ 'ComponentName' = 'Component'; 'State' = 'State' }
                    "NoIssuesFound" = $false
                    "ElapsedTime" = (Get-Date).Subtract((Get-Date).AddMinutes(-1))
                    "OutputValues" = @()
                }
            )

            $totalElapsedTime = (Get-Date).Subtract((Get-Date).AddMinutes(-3))

            Mock -CommandName Send-EmailMonitoringMessage -ModuleName PoShMon -Verifiable -MockWith { return } -ParameterFilter { $Critical -eq $true }
            Mock -CommandName Send-PushbulletMonitoringMessage -ModuleName PoShMon -Verifiable -MockWith { return } -ParameterFilter { $Critical -eq $true }

            $actual = Send-MonitoringNotifications $poShMonConfiguration $poShMonConfiguration.Notifications.Sinks $poShMonConfiguration.Notifications.When $testMonitoringOutput $totalElapsedTime
        
            Assert-VerifiableMock
        }
    }
}
Describe "Send-MonitoringNotifications-New-Scope" {
    InModuleScope PoShMon {

        It "Should send notifications to ONLY the specified channels (email, Pushbullet, O365 Teams)" {

            #$o365TeamsConfig = Get-Content -Raw -Path $o365TeamsConfigPath | ConvertFrom-Json

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General `
                                -EnvironmentName 'SharePoint' `
                                -MinutesToScanHistory 60 `
                                -PrimaryServerName 'APPServer1' `
                                -ConfigurationName SpFarmPosh `
                                -SkipVersionUpdateCheck `
                                -TestsToSkip 'SPServerStatus','WindowsServiceState','SPFailingTimerJobs','SPDatabaseHealth','SPSearchHealth','SPDistributedCacheHealth','WebTests'
                            Notifications -When All {
                                Email -ToAddress "hilton@email.com" -FromAddress "all@jones.com" -SmtpServer "smtp.company.com"
                                Pushbullet -AccessToken "TestAccessToken" -DeviceId "TestDeviceID"
                            }
                        }

            $testMonitoringOutput = @(
                @{
                    "SectionHeader" = "Grouped Test With A Long Name"
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

            $totalElapsedTime = (Get-Date).Subtract((Get-Date).AddMinutes(-3))

            Mock -CommandName Send-EmailMonitoringMessage -ModuleName PoShMon -Verifiable -MockWith {
                return
            }
            Mock -CommandName Send-PushbulletMonitoringMessage -ModuleName PoShMon -Verifiable -MockWith {
                return
            }
            Mock -CommandName Send-O365TeamsMonitoringMessage -ModuleName PoShMon -MockWith {
                return
            }

            $actual = Send-MonitoringNotifications $poShMonConfiguration $poShMonConfiguration.Notifications.Sinks "All" $testMonitoringOutput $totalElapsedTime
        
            Assert-VerifiableMock
            Assert-MockCalled -CommandName Send-O365TeamsMonitoringMessage -Times 0
        }

    }
}
Describe "Send-MonitoringNotifications-New-Scope2" {
    InModuleScope PoShMon {

        Mock -CommandName Send-EmailMonitoringMessage -ModuleName PoShMon -Verifiable -MockWith { return } -ParameterFilter { $Critical -eq $false }
        Mock -CommandName Send-PushbulletMonitoringMessage -ModuleName PoShMon -Verifiable -MockWith { return } -ParameterFilter { $Critical -eq $false }


        It "Should mark non-failures as NOT Critical" {

            #$o365TeamsConfig = Get-Content -Raw -Path $o365TeamsConfigPath | ConvertFrom-Json

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General `
                                -EnvironmentName 'SharePoint' `
                                -MinutesToScanHistory 60 `
                                -PrimaryServerName 'APPServer1' `
                                -ConfigurationName SpFarmPosh `
                                -SkipVersionUpdateCheck `
                                -TestsToSkip 'SPServerStatus','WindowsServiceState','SPFailingTimerJobs','SPDatabaseHealth','SPSearchHealth','SPDistributedCacheHealth','WebTests'
                            Notifications -When OnlyOnFailure {
                                Email -ToAddress "hilton@email.com" -FromAddress "all@jones.com" -SmtpServer "smtp.company.com"
                                Pushbullet -AccessToken "TestAccessToken" -DeviceId "TestDeviceID"
                            }
                        }

            $testMonitoringOutput = @(
                @{
                    "SectionHeader" = "Grouped Test With A Long Name"
                    "OutputHeaders" = @{ 'EventID' = 'Event ID'; 'Message' ='Message' }
                    "NoIssuesFound" = $true
                    "ElapsedTime" = (Get-Date).Subtract((Get-Date).AddMinutes(-1))
                    "OutputValues" = @()
                }
                @{
                    "SectionHeader" = "Ungrouped Test"
                    "OutputHeaders" = @{ 'ComponentName' = 'Component'; 'State' = 'State' }
                    "NoIssuesFound" = $true
                    "ElapsedTime" = (Get-Date).Subtract((Get-Date).AddMinutes(-1))
                    "OutputValues" = @()
                }
            )

            $totalElapsedTime = (Get-Date).Subtract((Get-Date).AddMinutes(-3))


            $actual = Send-MonitoringNotifications $poShMonConfiguration $poShMonConfiguration.Notifications.Sinks $poShMonConfiguration.Notifications.When $testMonitoringOutput $totalElapsedTime
        
            Assert-VerifiableMock
        }

        It "Should mark failures as NOT Critical when 'All' set" {

            #$o365TeamsConfig = Get-Content -Raw -Path $o365TeamsConfigPath | ConvertFrom-Json

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General `
                                -EnvironmentName 'SharePoint' `
                                -MinutesToScanHistory 60 `
                                -PrimaryServerName 'APPServer1' `
                                -ConfigurationName SpFarmPosh `
                                -SkipVersionUpdateCheck `
                                -TestsToSkip 'SPServerStatus','WindowsServiceState','SPFailingTimerJobs','SPDatabaseHealth','SPSearchHealth','SPDistributedCacheHealth','WebTests'
                            Notifications -When All {
                                Email -ToAddress "hilton@email.com" -FromAddress "all@jones.com" -SmtpServer "smtp.company.com"
                                Pushbullet -AccessToken "TestAccessToken" -DeviceId "TestDeviceID"
                            }
                        }

            $testMonitoringOutput = @(
                @{
                    "SectionHeader" = "Grouped Test With A Long Name"
                    "OutputHeaders" = @{ 'EventID' = 'Event ID'; 'Message' ='Message' }
                    "NoIssuesFound" = $true
                    "ElapsedTime" = (Get-Date).Subtract((Get-Date).AddMinutes(-1))
                    "OutputValues" = @()
                }
                @{
                    "SectionHeader" = "Ungrouped Test"
                    "OutputHeaders" = @{ 'ComponentName' = 'Component'; 'State' = 'State' }
                    "NoIssuesFound" = $false
                    "ElapsedTime" = (Get-Date).Subtract((Get-Date).AddMinutes(-1))
                    "OutputValues" = @()
                }
            )

            $totalElapsedTime = (Get-Date).Subtract((Get-Date).AddMinutes(-3))

            $actual = Send-MonitoringNotifications $poShMonConfiguration $poShMonConfiguration.Notifications.Sinks $poShMonConfiguration.Notifications.When $testMonitoringOutput $totalElapsedTime
        
            Assert-VerifiableMock
        }
    }
}