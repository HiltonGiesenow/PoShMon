$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\..\..\') -Resolve
Remove-Module PoShMon -ErrorAction SilentlyContinue
Import-Module (Join-Path $rootPath -ChildPath "PoShMon.psd1")

$o365TeamsConfigPath = [Environment]::GetFolderPath("MyDocuments") + "\o365TeamsConfig.json"

Describe "Send-RepairNotifications" {
    It "Should send notifications to the specified channels (email, Pushbullet, O365 Teams)" {

        $poShMonConfiguration = New-PoShMonConfiguration {
                        New-GeneralConfig `
                            -EnvironmentName 'SharePoint' `
                            -MinutesToScanHistory 60 `
                            -PrimaryServerName 'APPServer1' `
                            -ConfigurationName SpFarmPosh `
                            -TestsToSkip 'SPServerStatus','WindowsServiceState','SPFailingTimerJobs','SPDatabaseHealth','SPSearchHealth','SPDistributedCacheHealth','WebTests'
                        New-NotificationsConfig -When All {
                            New-EmailConfig -ToAddress "hilton@email.com" -FromAddress "all@jones.com" -SmtpServer "smtp.company.com"
                            New-PushBulletConfig -AccessToken "TestAccessToken" -DeviceId "TestDeviceID"
                            New-O365TeamsConfig -TeamsWebHookUrl "http://teams.office.com/theapi"
                        }
                    }

        $repairOutput = @(
            @{
                "SectionHeader" = "Repair 1"
                "RepairResult" = "Something Important Was Done"
            }
        )

        Mock -CommandName Send-PoShMonEmail -ModuleName PoShMon -Verifiable -MockWith {
            return
        }
        Mock -CommandName Send-PushbulletMessage -ModuleName PoShMon -Verifiable -MockWith {
            return
        }
        Mock -CommandName Send-O365TeamsMessage -ModuleName PoShMon -Verifiable -MockWith {
            return
        }

        $actual = Send-RepairNotifications $poShMonConfiguration $poShMonConfiguration.Notifications.Sinks $repairOutput -Verbose

        Assert-VerifiableMock
    }

    It "Should send notifications to ONLY the specified channels (email, Pushbullet, O365 Teams)" {

        #$o365TeamsConfig = Get-Content -Raw -Path $o365TeamsConfigPath | ConvertFrom-Json

        $poShMonConfiguration = New-PoShMonConfiguration {
                        New-GeneralConfig `
                            -EnvironmentName 'SharePoint' `
                            -MinutesToScanHistory 60 `
                            -PrimaryServerName 'APPServer1' `
                            -ConfigurationName SpFarmPosh `
                            -TestsToSkip 'SPServerStatus','WindowsServiceState','SPFailingTimerJobs','SPDatabaseHealth','SPSearchHealth','SPDistributedCacheHealth','WebTests'
                        New-NotificationsConfig -When All {
                            New-EmailConfig -ToAddress "hilton@email.com" -FromAddress "all@jones.com" -SmtpServer "smtp.company.com"
                            New-PushBulletConfig -AccessToken "TestAccessToken" -DeviceId "TestDeviceID"
                        }
                    }

        $repairOutput = @(
            @{
                "SectionHeader" = "Repair 1"
                "RepairResult" = "Something Important Was Done"
            }
        )

        Mock -CommandName Send-PoShMonEmail -ModuleName PoShMon -Verifiable -MockWith {
            return
        }
        Mock -CommandName Send-PushbulletMessage -ModuleName PoShMon -Verifiable -MockWith {
            return
        }
        Mock -CommandName Send-O365TeamsMessage -ModuleName PoShMon -MockWith {
            throw "Should not get here..."
        }

        $actual = Send-RepairNotifications $poShMonConfiguration $poShMonConfiguration.Notifications.Sinks $repairOutput -Verbose

        Assert-VerifiableMock
    }
}