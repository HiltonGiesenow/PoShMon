$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\..\..\') -Resolve
Remove-Module PoShMon -ErrorAction SilentlyContinue
Import-Module (Join-Path $rootPath -ChildPath "PoShMon.psd1")

Describe "New-PoShMonConfiguration" {
    It "Should work with a minimal configuration" {

        $env:COMPUTERNAME = "THESERVERNAME"
        $poShMonConfiguration = New-PoShMonConfiguration {}
        
        $poShMonConfiguration.General.ServerNames | Should Be "THESERVERNAME"
        $poShMonConfiguration.General.PrimaryServerName | Should Be ""
    }

    It "Should work with a full configuration (Servers list)" {

        $poShMonConfiguration = New-PoShMonConfiguration {
                        New-GeneralConfig `
                            -EnvironmentName 'OS Base Test' `
                            -MinutesToScanHistory 60 `
                            -ServerNames 'Server01','Server02' `
                            -ConfigurationName SpFarmPosh `
                            -TestsToSkip 'Memory'
                        New-NotificationsConfig -When All {
                            New-EmailConfig -ToAddress "someone@email.com" -FromAddress "all@jones.com" -SmtpServer "smtp.company.com"
                            New-PushBulletConfig -AccessToken "TestAccessToken" -DeviceId "TestDeviceID"
                            New-O365TeamsConfig -TeamsWebHookUrl "http://teams.office.com/theapi"
                        }               
                    }

        $poShMonConfiguration.General.ServerNames | Should Be 'Server01','Server02'
        $poShMonConfiguration.General.PrimaryServerName | Should Be ""
    }

    It "Should work with a full configuration (primary server)" {

        $poShMonConfiguration = New-PoShMonConfiguration {
                        New-GeneralConfig `
                            -EnvironmentName 'OS Base Test' `
                            -MinutesToScanHistory 60 `
                            -PrimaryServerName "Server1" `
                            -ConfigurationName SpFarmPosh `
                            -TestsToSkip 'Memory'
                        New-NotificationsConfig -When All {
                            New-EmailConfig -ToAddress "someone@email.com" -FromAddress "all@jones.com" -SmtpServer "smtp.company.com"
                            New-PushBulletConfig -AccessToken "TestAccessToken" -DeviceId "TestDeviceID"
                            New-O365TeamsConfig -TeamsWebHookUrl "http://teams.office.com/theapi"
                        }               
                    }

        $poShMonConfiguration.General.ServerNames | Should Be $null
        $poShMonConfiguration.General.PrimaryServerName | Should Be "Server1"
    }
}
