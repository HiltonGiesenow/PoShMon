$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\..\..\') -Resolve
Remove-Module PoShMon -ErrorAction SilentlyContinue
Import-Module (Join-Path $rootPath -ChildPath "PoShMon.psd1")

Describe "Invoke-MonitoringCore" {
    It "Should invoke core monitoring (non-farm)" {

        $poShMonConfiguration = New-PoShMonConfiguration {
                        General `
                            -EnvironmentName 'Core' `
                            -MinutesToScanHistory 60 `
                            -PrimaryServerName 'AppServer01' `
                            -ConfigurationName SpFarmPosh
                        Notifications -When All {
                            Email -ToAddress "someone@email.com" -FromAddress "all@jones.com" -SmtpServer "smtp.company.com"
                            Pushbullet -AccessToken "TestAccessToken" -DeviceId "TestDeviceID"
                            O365Teams -TeamsWebHookUrl "http://teams.office.com/theapi"
                        }               
                    }

        #Mock -CommandName Get-ServersInSPFarm -ModuleName PoShMon -Verifiable -MockWith {
        #    return "Server1","Server2","Server3"
        #}

        Mock -CommandName Invoke-Tests -ModuleName PoShMon -Verifiable -MockWith {
            Begin
            {
                $outputValues = @()
            }

            Process
            {
                foreach ($test in $TestToRuns)
                {
                    $outputValues += @{
                                    "SectionHeader" = "Mock Test: $test"
                                    "OutputHeaders" = @{ 'Item1' = 'Item 1'; }
                                    "NoIssuesFound" = $false
                                    "ElapsedTime" = (Get-Date).Subtract((Get-Date).AddMinutes(-1))
                                    "OutputValues" = @(
                                                        @{
                                                            "Item1" = 123
                                                            "State" = "State 1"
                                                        }
                                                    )
                                }
                }
            }
    
            End
            {
                return $outputValues
            }
        }

        Mock -CommandName Initialize-Notifications -ModuleName PoShMon -Verifiable -MockWith {
            Write-Verbose "Final Output Received:"
            $TestOutputValues | % { Write-Verbose "`t$($_.SectionHeader)" }
            return
        }

        #Mock -CommandName Get-PSSession -Verifiable -MockWith {
        #    return $null
        #}

        $actual = Invoke-MonitoringCore $poShMonConfiguration -TestList "Test1","Test2" -Verbose

        Assert-VerifiableMock
    }

    It "Should send a notification for an exception OUTSIDE the tests" {

        $poShMonConfiguration = New-PoShMonConfiguration {
                        General `
                            -EnvironmentName 'SharePoint' `
                            -MinutesToScanHistory 60 `
                            -PrimaryServerName 'AppServer01' `
                            -ConfigurationName SpFarmPosh
                        Notifications -When All {
                            Email -ToAddress "someone@email.com" -FromAddress "all@jones.com" -SmtpServer "smtp.company.com"
                            Pushbullet -AccessToken "TestAccessToken" -DeviceId "TestDeviceID"
                            O365Teams -TeamsWebHookUrl "http://teams.office.com/theapi"
                        }               
                    }

        Mock -CommandName Get-ServersInSPFarm -ModuleName PoShMon -Verifiable -MockWith {
            throw "Fake Exception"
        }

        Mock -CommandName Initialize-Notifications -ModuleName PoShMon -Verifiable -MockWith {
            Write-Verbose "Final Output Received:"
            $TestOutputValues | % { Write-Verbose "`t$($_.SectionHeader)" }
            return
        }

        Mock -CommandName Send-ExceptionNotifications -ModuleName PoShMon -Verifiable -MockWith {
            return $null
        }

        Invoke-MonitoringCore $poShMonConfiguration -TestList "Test1","Test2" -FarmDiscoveryFunctionName 'Get-ServersInSPFarm'

        Assert-VerifiableMock
    }
}
Describe "Invoke-MonitoringCore (New Scope)" {
        
        Mock -CommandName Test-SPServerStatus -ModuleName PoShMon -Verifiable -MockWith {
            return @{
                        "SectionHeader" = "SPServerStatus Mock"
                        "OutputHeaders" = @{ 'Item1' = 'Item 1'; }
                        "NoIssuesFound" = $false
                        "ElapsedTime" = (Get-Date).Subtract((Get-Date).AddMinutes(-1))
                        "OutputValues" = @(
                                            [PSCustomObject]@{
                                                "Item1" = 123
                                                "State" = "State 1"
                                            }
                                        )
                    }
        }

        Mock -CommandName Test-SPJobHealth -ModuleName PoShMon -Verifiable -MockWith {
            throw "something"
        }

        Mock -CommandName Send-ExceptionNotifications -ModuleName PoShMon -MockWith {
            throw "Should not get here"
        }

        Mock -CommandName Initialize-Notifications -ModuleName PoShMon -Verifiable -MockWith {
            Write-Verbose "Final Output Received:"
            $TestOutputValues | % { Write-Verbose "`t$($_.SectionHeader)" }
            return
        }

    It "Should NOT send a notification for an exception INSIDE the tests" {

        $poShMonConfiguration = New-PoShMonConfiguration {
                        General `
                            -EnvironmentName 'SharePoint' `
                            -MinutesToScanHistory 60 `
                            -PrimaryServerName 'AppServer01' `
                            -ConfigurationName SpFarmPosh
                        Notifications -When All {
                            Email -ToAddress "someone@email.com" -FromAddress "all@jones.com" -SmtpServer "smtp.company.com"
                            Pushbullet -AccessToken "TestAccessToken" -DeviceId "TestDeviceID"
                            O365Teams -TeamsWebHookUrl "http://teams.office.com/theapi"
                        }               
                    }

        $actual = Invoke-MonitoringCore $poShMonConfiguration -TestList "SPServerStatus","SPJobHealth"

        Assert-VerifiableMock

        $actual[1].Exception.Message | Should Be "something"
    }

    It "Should include additional supplied tests" {

        $extraTestsToInclude = @(
                                    (Join-Path $rootPath -ChildPath "Tests\CI\Integration\PoShMon.Monitoring.Core\Dummy-Test.ps1")
                                )

        $poShMonConfiguration = New-PoShMonConfiguration {
                        General `
                            -EnvironmentName 'SharePoint' `
                            -MinutesToScanHistory 60 `
                            -PrimaryServerName 'AppServer01' `
                            -ConfigurationName SpFarmPosh
                        Extensibility `
                            -ExtraTestFilesToInclude $extraTestsToInclude
                        Notifications -When All {
                            Email -ToAddress "someone@email.com" -FromAddress "all@jones.com" -SmtpServer "smtp.company.com"
                            Pushbullet -AccessToken "TestAccessToken" -DeviceId "TestDeviceID"
                            O365Teams -TeamsWebHookUrl "http://teams.office.com/theapi"
                        }               
                    }

        $actual = Invoke-MonitoringCore $poShMonConfiguration -TestList "SPServerStatus"

        Assert-VerifiableMock

        $actual.Count | Should Be 2
        $actual[1].SectionHeader | Should Be "Dummy Test Section"
    }

    It "Should warn on additional supplied tests that don't exist" {

        $extraTestsToInclude = @(
                                    (Join-Path $rootPath -ChildPath "Tests\CI\Integration\PoShMon.Monitoring.Core\Dummy-Test.ps1"),
                                    (Join-Path $rootPath -ChildPath "Tests\CI\Integration\PoShMon.Monitoring.Core\NotExistingDummy-Test.ps1")
                                )

        $poShMonConfiguration = New-PoShMonConfiguration {
                        General `
                            -EnvironmentName 'SharePoint' `
                            -MinutesToScanHistory 60 `
                            -PrimaryServerName 'AppServer01' `
                            -ConfigurationName SpFarmPosh
                        Extensibility `
                            -ExtraTestFilesToInclude $extraTestsToInclude
                        Notifications -When All {
                            Email -ToAddress "someone@email.com" -FromAddress "all@jones.com" -SmtpServer "smtp.company.com"
                            Pushbullet -AccessToken "TestAccessToken" -DeviceId "TestDeviceID"
                            O365Teams -TeamsWebHookUrl "http://teams.office.com/theapi"
                        }               
                    }

        $actual = Invoke-MonitoringCore $poShMonConfiguration -TestList "SPServerStatus"
        $actual.Count | Should Be 2
        $actual[1].SectionHeader | Should Be "Dummy Test Section"

        $output = $($actual = Invoke-MonitoringCore $poShMonConfiguration -TestList "SPServerStatus") 3>&1

        $output.Count | Should Be 1
        $output[0].ToString().StartsWith("Test file not found") | Should Be $true
        $output[0].ToString().EndsWith("NotExistingDummy-Test.ps1") | Should Be $true

        Assert-VerifiableMock
    }

    It "Should handle exceptions inside additional supplied tests" {

        $extraTestsToInclude = @(
                                    (Join-Path $rootPath -ChildPath "Tests\CI\Integration\PoShMon.Monitoring.Core\Dummy-TestWithException.ps1")
                                )

        $poShMonConfiguration = New-PoShMonConfiguration {
                        General `
                            -EnvironmentName 'SharePoint' `
                            -MinutesToScanHistory 60 `
                            -PrimaryServerName 'AppServer01' `
                            -ConfigurationName SpFarmPosh
                        Extensibility `
                            -ExtraTestFilesToInclude $extraTestsToInclude
                        Notifications -When All {
                            Email -ToAddress "someone@email.com" -FromAddress "all@jones.com" -SmtpServer "smtp.company.com"
                            Pushbullet -AccessToken "TestAccessToken" -DeviceId "TestDeviceID"
                            O365Teams -TeamsWebHookUrl "http://teams.office.com/theapi"
                        }               
                    }

        $actual = Invoke-MonitoringCore $poShMonConfiguration -TestList "SPServerStatus"

        Assert-VerifiableMock

        $actual[1].Exception.Message | Should Be "something"
    }

    It "Should include additional supplied resolvers" {

        $extraResolverFilesToInclude = @(
                                    (Join-Path $rootPath -ChildPath "Tests\CI\Integration\PoShMon.Monitoring.Core\Dummy-Resolver.ps1")
                                )

        $poShMonConfiguration = New-PoShMonConfiguration {
                        General `
                            -EnvironmentName 'SharePoint' `
                            -MinutesToScanHistory 60 `
                            -PrimaryServerName 'AppServer01' `
                            -ConfigurationName SpFarmPosh
                        Extensibility `
                            -ExtraResolverFilesToInclude $extraResolverFilesToInclude
                        Notifications -When All {
                            Email -ToAddress "someone@email.com" -FromAddress "all@jones.com" -SmtpServer "smtp.company.com"
                            Pushbullet -AccessToken "TestAccessToken" -DeviceId "TestDeviceID"
                            O365Teams -TeamsWebHookUrl "http://teams.office.com/theapi"
                        }               
                    }

        $actual = Invoke-MonitoringCore $poShMonConfiguration -TestList "SPServerStatus"

        Assert-VerifiableMock

        $actual.NoIssuesFound | Should Be $true
    }

    It "Should warn on additional supplied resolvers that don't exist" {

        $extraResolverFilesToInclude = @(
                                    (Join-Path $rootPath -ChildPath "Tests\CI\Integration\PoShMon.Monitoring.Core\Dummy-Resolver.ps1")
                                    (Join-Path $rootPath -ChildPath "Tests\CI\Integration\PoShMon.Monitoring.Core\Dummy-ResolverThatDoesntExist.ps1")
                                )

        $poShMonConfiguration = New-PoShMonConfiguration {
                        General `
                            -EnvironmentName 'SharePoint' `
                            -MinutesToScanHistory 60 `
                            -PrimaryServerName 'AppServer01' `
                            -ConfigurationName SpFarmPosh
                        Extensibility `
                            -ExtraResolverFilesToInclude $extraResolverFilesToInclude
                        Notifications -When All {
                            Email -ToAddress "someone@email.com" -FromAddress "all@jones.com" -SmtpServer "smtp.company.com"
                            Pushbullet -AccessToken "TestAccessToken" -DeviceId "TestDeviceID"
                            O365Teams -TeamsWebHookUrl "http://teams.office.com/theapi"
                        }               
                    }



        $actual = Invoke-MonitoringCore $poShMonConfiguration -TestList "SPServerStatus"
        $actual.NoIssuesFound | Should Be $true

        Assert-VerifiableMock

        $output = $($actual = Invoke-MonitoringCore $poShMonConfiguration -TestList "SPServerStatus") 3>&1

        $output.Count | Should Be 1
        $output[0].ToString().StartsWith("Resolver file not found, will be skipped:") | Should Be $true
        $output[0].ToString().EndsWith("Dummy-ResolverThatDoesntExist.ps1") | Should Be $true
    }

    It "Should include additional supplied mergers" {

        $extraMergerFilesToInclude = @(
                                    (Join-Path $rootPath -ChildPath "Tests\CI\Integration\PoShMon.Monitoring.Core\Dummy-Merger.ps1")
                                )

        $poShMonConfiguration = New-PoShMonConfiguration {
                        General `
                            -EnvironmentName 'SharePoint' `
                            -MinutesToScanHistory 60 `
                            -PrimaryServerName 'AppServer01' `
                            -ConfigurationName SpFarmPosh
                        Extensibility `
                            -ExtraMergerFilesToInclude $extraMergerFilesToInclude
                        Notifications -When All {
                            Email -ToAddress "someone@email.com" -FromAddress "all@jones.com" -SmtpServer "smtp.company.com"
                            Pushbullet -AccessToken "TestAccessToken" -DeviceId "TestDeviceID"
                            O365Teams -TeamsWebHookUrl "http://teams.office.com/theapi"
                        }               
                    }

        Mock -CommandName Test-CPULoad -ModuleName PoShMon -Verifiable -MockWith {
            return @{
                        "SectionHeader" = "CPULoad Mock"
                        "OutputHeaders" = @{ 'Server' = 'Server'; }
                        "NoIssuesFound" = $false
                        "ElapsedTime" = (Get-Date).Subtract((Get-Date).AddMinutes(-1))
                        "OutputValues" = @(
                                            [PSCustomObject]@{
                                                "Server" = 'Server1'
                                                "Load" = "50%"
                                            }
                                        )
                    }
        }

        $actual = Invoke-MonitoringCore $poShMonConfiguration -TestList "SPServerStatus", "CPULoad"

        Assert-VerifiableMock

        $actual.SectionHeader | Should Be "New Merger Mock"
    }

    It "Should warn on additional supplied mergers that don't exist" {

        $extraMergerFilesToInclude = @(
                                    (Join-Path $rootPath -ChildPath "Tests\CI\Integration\PoShMon.Monitoring.Core\Dummy-Merger.ps1")
                                    (Join-Path $rootPath -ChildPath "Tests\CI\Integration\PoShMon.Monitoring.Core\Dummy-MergerThatDoesntExist.ps1")
                                )

        $poShMonConfiguration = New-PoShMonConfiguration {
                        General `
                            -EnvironmentName 'SharePoint' `
                            -MinutesToScanHistory 60 `
                            -PrimaryServerName 'AppServer01' `
                            -ConfigurationName SpFarmPosh
                        Extensibility `
                            -ExtraMergerFilesToInclude $extraMergerFilesToInclude
                        Notifications -When All {
                            Email -ToAddress "someone@email.com" -FromAddress "all@jones.com" -SmtpServer "smtp.company.com"
                            Pushbullet -AccessToken "TestAccessToken" -DeviceId "TestDeviceID"
                            O365Teams -TeamsWebHookUrl "http://teams.office.com/theapi"
                        }               
                    }



        $actual = Invoke-MonitoringCore $poShMonConfiguration -TestList "SPServerStatus", "CPULoad"
        $actual.NoIssuesFound | Should Be $true

        Assert-VerifiableMock

        $output = $($actual = Invoke-MonitoringCore $poShMonConfiguration -TestList "SPServerStatus", "CPULoad") 3>&1

        $output.Count | Should Be 1
        $output[0].ToString().StartsWith("Merger file not found, will be skipped:") | Should Be $true
        $output[0].ToString().EndsWith("Dummy-MergerThatDoesntExist.ps1") | Should Be $true
    }
}

Describe "Invoke-MonitoringCore (Exception Scope)" {

    Mock -CommandName AutoDiscover-ServerNames -ModuleName PoShMon -MockWith {
        throw "The Exception"
    }

    Mock -CommandName Send-ExceptionNotifications -ModuleName PoShMon -MockWith {
    }

    Mock -CommandName Initialize-Notifications -ModuleName PoShMon -Verifiable -MockWith {
        Write-Verbose "Final Output Received:"
        $TestOutputValues | % { Write-Verbose "`t$($_.SectionHeader)" }
        return
    }

It "Should notify for exceptions in the main process" {

    $poShMonConfiguration = New-PoShMonConfiguration {
                    General `
                        -EnvironmentName 'SharePoint' `
                        -MinutesToScanHistory 60 `
                        -PrimaryServerName 'AppServer01' `
                        -ConfigurationName SpFarmPosh
                    Notifications -When All {
                        Email -ToAddress "someone@email.com" -FromAddress "all@jones.com" -SmtpServer "smtp.company.com"
                    }               
                }

    $actual = Invoke-MonitoringCore $poShMonConfiguration -TestList "SPServerStatus"

    Assert-VerifiableMock
}

It "Should store exceptions in the main process for later" {

    $poShMonConfiguration = New-PoShMonConfiguration {
                    General `
                        -EnvironmentName 'SharePoint' `
                        -MinutesToScanHistory 60 `
                        -PrimaryServerName 'AppServer01' `
                        -ConfigurationName SpFarmPosh
                    Notifications -When All {
                        Email -ToAddress "someone@email.com" -FromAddress "all@jones.com" -SmtpServer "smtp.company.com"
                    }               
                }

    $actual = Invoke-MonitoringCore $poShMonConfiguration -TestList "SPServerStatus"

    $Global:PoShMon_GlobalException | Should Not Be $null
    $Global:PoShMon_GlobalException.Message | Should Be "The Exception"
}

}