$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\..\..\') -Resolve
Remove-Module PoShMon -ErrorAction SilentlyContinue
Import-Module (Join-Path $rootPath -ChildPath "PoShMon.psd1")

$o365TeamsConfigPath = [Environment]::GetFolderPath("MyDocuments") + "\o365TeamsConfig.json"

Describe "Send-RepairNotifications" {

   InModuleScope PoShMon {

        It "Should send notifications to the specified channels (email, Pushbullet, O365 Teams)" {

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General `
                                -EnvironmentName 'SharePoint' `
                                -MinutesToScanHistory 60 `
                                -PrimaryServerName 'APPServer1' `
                                -ConfigurationName SpFarmPosh `
                                -TestsToSkip 'SPServerStatus','WindowsServiceState','SPFailingTimerJobs','SPDatabaseHealth','SPSearchHealth','SPDistributedCacheHealth','WebTests'
                            Notifications -When All {
                                Email -ToAddress "hilton@email.com" -FromAddress "all@jones.com" -SmtpServer "smtp.company.com"
                                Pushbullet -AccessToken "TestAccessToken" -DeviceId "TestDeviceID"
                                O365Teams -TeamsWebHookUrl "http://teams.office.com/theapi"
                            }
                        }

            $repairOutput = @(
                @{
                    "SectionHeader" = "Repair 1"
                    "RepairResult" = "Something Important Was Done"
                }
            )

            Mock -CommandName Send-EmailRepairMessage -ModuleName PoShMon -Verifiable -MockWith {
                return
            }
            Mock -CommandName Send-PushbulletRepairMessage -ModuleName PoShMon -Verifiable -MockWith {
                return
            }
            Mock -CommandName Send-O365TeamsRepairMessage -ModuleName PoShMon -MockWith {
                return
            }

            $actual = Send-RepairNotifications $poShMonConfiguration $poShMonConfiguration.Notifications.Sinks $repairOutput -Verbose

            Assert-VerifiableMock
            Assert-MockCalled -CommandName Send-O365TeamsRepairMessage -Times 1
        }
    }
}
Describe "Send-RepairNotifications-New-Scope" {

   InModuleScope PoShMon {
        It "Should send notifications to ONLY the specified channels (email, Pushbullet, O365 Teams)" {

            #$o365TeamsConfig = Get-Content -Raw -Path $o365TeamsConfigPath | ConvertFrom-Json

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General `
                                -EnvironmentName 'SharePoint' `
                                -MinutesToScanHistory 60 `
                                -PrimaryServerName 'APPServer1' `
                                -ConfigurationName SpFarmPosh `
                                -TestsToSkip 'SPServerStatus','WindowsServiceState','SPFailingTimerJobs','SPDatabaseHealth','SPSearchHealth','SPDistributedCacheHealth','WebTests'
                            Notifications -When All {
                                Email -ToAddress "hilton@email.com" -FromAddress "all@jones.com" -SmtpServer "smtp.company.com"
                                Pushbullet -AccessToken "TestAccessToken" -DeviceId "TestDeviceID"
                            }
                        }

            $repairOutput = @(
                @{
                    "SectionHeader" = "Repair 1"
                    "RepairResult" = "Something Important Was Done"
                }
            )

            Mock -CommandName Send-EmailRepairMessage -ModuleName PoShMon -Verifiable -MockWith {
                return
            }
            Mock -CommandName Send-PushbulletRepairMessage -ModuleName PoShMon -Verifiable -MockWith {
                return
            }
            Mock -CommandName Send-O365TeamsRepairMessage -ModuleName PoShMon -MockWith {
                return
            }

            $actual = Send-RepairNotifications $poShMonConfiguration $poShMonConfiguration.Notifications.Sinks $repairOutput -Verbose

            Assert-VerifiableMock
            Assert-MockCalled -CommandName Send-O365TeamsRepairMessage -Times 0
        }
    }
}