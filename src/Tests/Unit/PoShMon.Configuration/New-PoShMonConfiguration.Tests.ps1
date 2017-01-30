$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\..\') -Resolve
Remove-Module PoShMon -ErrorAction SilentlyContinue
Import-Module (Join-Path $rootPath -ChildPath "PoShMon.psd1")

Describe "Invoke-OSMonitoring" {
    It "Should work with a minimal configuration" {

        $env:COMPUTERNAME = "THESERVERNAME"
        $poShMonConfiguration = New-PoShMonConfiguration {}
        
        $poShMonConfiguration.General.ServerNames | Should Be "THESERVERNAME"
        $poShMonConfiguration.General.PrimaryServerName | Should Be ""
    }

    It "Should work with a full configuration (Servers list)" {

        $poShMonConfiguration = New-PoShMonConfiguration {
                        General `
                            -EnvironmentName 'OS Base Test' `
                            -MinutesToScanHistory 60 `
                            -ServerNames 'Server01','Server02' `
                            -ConfigurationName SpFarmPosh `
                            -TestsToSkip 'Memory'
                        Notifications -When All {
                            Email -ToAddress "hilton@giesenow.com" -FromAddress "all@jones.com" -SmtpServer "smtp.company.com"
                            Pushbullet -AccessToken "TestAccessToken" -DeviceId "TestDeviceID"
                            O365Teams -TeamsWebHookUrl "http://teams.office.com/theapi"
                        }               
                    }

        $poShMonConfiguration.General.ServerNames | Should Be 'Server01','Server02'
        $poShMonConfiguration.General.PrimaryServerName | Should Be ""
    }

    It "Should work with a full configuration (primary server)" {

        $poShMonConfiguration = New-PoShMonConfiguration {
                        General `
                            -EnvironmentName 'OS Base Test' `
                            -MinutesToScanHistory 60 `
                            -PrimaryServerName "Server1" `
                            -ConfigurationName SpFarmPosh `
                            -TestsToSkip 'Memory'
                        Notifications -When All {
                            Email -ToAddress "hilton@giesenow.com" -FromAddress "all@jones.com" -SmtpServer "smtp.company.com"
                            Pushbullet -AccessToken "TestAccessToken" -DeviceId "TestDeviceID"
                            O365Teams -TeamsWebHookUrl "http://teams.office.com/theapi"
                        }               
                    }

        $poShMonConfiguration.General.ServerNames | Should Be @()
        $poShMonConfiguration.General.PrimaryServerName | Should Be "Server1"
    }
}
.