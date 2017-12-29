$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\..\..\') -Resolve
Remove-Module PoShMon -ErrorAction SilentlyContinue
Import-Module (Join-Path $rootPath -ChildPath "PoShMon.psd1")

#. (Join-Path $rootPath -ChildPath "Tests\CI\Integration\PoShMon.SelfHealing.Core\Dummy-Repair.ps1")
#. (Join-Path $rootPath -ChildPath "Tests\CI\Integration\PoShMon.SelfHealing.Core\Dummy-Repair2.ps1")

Describe "Repair-Environment" {

    InModuleScope PoShMon {

        It "Should send notifications of repairs" {

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General `
                                -EnvironmentName 'Core' `
                                -PrimaryServerName 'Svr1'
                            Notifications -When All {
                                Email -ToAddress "someone@email.com" -FromAddress "all@jones.com" -SmtpServer "smtp.company.com"
                                Pushbullet -AccessToken "TestAccessToken" -DeviceId "TestDeviceID"
                                O365Teams -TeamsWebHookUrl "http://teams.office.com/theapi"
                            }               
                        }

            $monitoringOutput = [System.Collections.ArrayList]@(
                @{
                    "SectionHeader" = "AMonitoringTest"
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

            $RepairScripts = @(
                                (Join-Path $rootPath -ChildPath "Tests\CI\Integration\PoShMon.SelfHealing.Core\Dummy-Repair.ps1")        
            )

            Mock -CommandName Initialize-RepairNotifications -ModuleName PoShMon -Verifiable -MockWith {
                $RepairOutputValues.SectionHeader | Should Be "Mock Repair"
                $RepairOutputValues.RepairResult | Should Be "Some repair message"
            }

            $actual = Repair-Environment $poShMonConfiguration $monitoringOutput $RepairScripts -Verbose

            Assert-VerifiableMock
        }

        It "Should send notifications of exceptions in repairs" {

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General `
                                -EnvironmentName 'Core' `
                                -PrimaryServerName 'Svr1'
                            Notifications -When All {
                                Email -ToAddress "someone@email.com" -FromAddress "all@jones.com" -SmtpServer "smtp.company.com"
                                Pushbullet -AccessToken "TestAccessToken" -DeviceId "TestDeviceID"
                                O365Teams -TeamsWebHookUrl "http://teams.office.com/theapi"
                            }               
                        }

            $monitoringOutput = [System.Collections.ArrayList]@(
                @{
                    "SectionHeader" = "AMonitoringTest"
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

            $RepairScripts = @(
                                (Join-Path $rootPath -ChildPath "Tests\CI\Integration\PoShMon.SelfHealing.Core\Failing-Repair.ps1")        
            )

            Mock -CommandName Initialize-RepairNotifications -ModuleName PoShMon -Verifiable -MockWith {
                $RepairOutputValues.SectionHeader | Should Be "Failing-Repair"
            }

            $actual = Repair-Environment $poShMonConfiguration $monitoringOutput $RepairScripts -Verbose

            Assert-VerifiableMock
        }

        It "Should send notifications of each repair performed" {

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General `
                                -EnvironmentName 'Core' `
                                -PrimaryServerName 'Svr1'
                            Notifications -When All {
                                Email -ToAddress "someone@email.com" -FromAddress "all@jones.com" -SmtpServer "smtp.company.com"
                                Pushbullet -AccessToken "TestAccessToken" -DeviceId "TestDeviceID"
                                O365Teams -TeamsWebHookUrl "http://teams.office.com/theapi"
                            }               
                        }

            $monitoringOutput = @(
                @{
                    "SectionHeader" = "AMonitoringTest"
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

            $RepairScripts = @(
                                (Join-Path $rootPath -ChildPath "Tests\CI\Integration\PoShMon.SelfHealing.Core\Dummy-Repair.ps1")        
                                (Join-Path $rootPath -ChildPath "Tests\CI\Integration\PoShMon.SelfHealing.Core\Dummy-Repair2.ps1")        
            )

            Mock -CommandName Initialize-RepairNotifications -ModuleName PoShMon -Verifiable -MockWith {
                $RepairOutputValues[0].SectionHeader | Should Be "Mock Repair"
                $RepairOutputValues[1].SectionHeader | Should Be "Another Mock Repair"
            }

            $actual = Repair-Environment $poShMonConfiguration $monitoringOutput $RepairScripts -Verbose

            Assert-VerifiableMock
        }

        It "Should send notifications of exceptions in repairs as well as successful repairs" {

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General `
                                -EnvironmentName 'Core' `
                                -PrimaryServerName 'Svr1'
                            Notifications -When All {
                                Email -ToAddress "someone@email.com" -FromAddress "all@jones.com" -SmtpServer "smtp.company.com"
                                Pushbullet -AccessToken "TestAccessToken" -DeviceId "TestDeviceID"
                                O365Teams -TeamsWebHookUrl "http://teams.office.com/theapi"
                            }               
                        }

            $monitoringOutput = @(
                @{
                    "SectionHeader" = "AMonitoringTest"
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

            $RepairScripts = @(
                                (Join-Path $rootPath -ChildPath "Tests\CI\Integration\PoShMon.SelfHealing.Core\Failing-Repair.ps1")        
                                (Join-Path $rootPath -ChildPath "Tests\CI\Integration\PoShMon.SelfHealing.Core\Dummy-Repair2.ps1")        
            )

            Mock -CommandName Initialize-RepairNotifications -ModuleName PoShMon -Verifiable -MockWith {
                $RepairOutputValues[0].SectionHeader | Should Be "Failing-Repair"
                $RepairOutputValues[1].SectionHeader | Should Be "Another Mock Repair"
            }

            $actual = Repair-Environment $poShMonConfiguration $monitoringOutput $RepairScripts -Verbose

            Assert-VerifiableMock
        }
    }
}
