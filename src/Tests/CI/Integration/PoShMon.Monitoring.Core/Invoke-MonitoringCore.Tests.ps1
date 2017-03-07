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

        Assert-VerifiableMocks
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

        Assert-VerifiableMocks
    }
}
Describe "Invoke-MonitoringCore (New Scope)" {
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

        Mock -CommandName Initialize-Notifications -ModuleName PoShMon -Verifiable -MockWith {
            Write-Verbose "Final Output Received:"
            $TestOutputValues | % { Write-Verbose "`t$($_.SectionHeader)" }
            return
        }

        Mock -CommandName Test-SPServerStatus -ModuleName PoShMon -Verifiable -MockWith {
            return @{
                        "SectionHeader" = "SPServerStatus Mock"
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

        Mock -CommandName Test-SPJobHealth -ModuleName PoShMon -Verifiable -MockWith {
            <#return @{
                        "SectionHeader" = "SPFailingTimerJobs Mock"
                        "OutputHeaders" = @{ 'Item1' = 'Item 1'; }
                        "NoIssuesFound" = $false
                        "ElapsedTime" = (Get-Date).Subtract((Get-Date).AddMinutes(-1))
                        "OutputValues" = @(
                                            @{
                                                "Item1" = 123
                                                "State" = "State 1"
                                            }
                                        )
                    }#>
            throw "something"
        }

        #Mock -CommandName Get-PSSession -Verifiable -MockWith {
        #    return $null
        #}

        Mock -CommandName Send-ExceptionNotifications -ModuleName PoShMon -MockWith {
            throw "Should not get here"
        }

        $actual = Invoke-MonitoringCore $poShMonConfiguration -TestList "SPServerStatus","SPJobHealth"

        Assert-VerifiableMocks

        $actual[1].Exception.Message | Should Be "something"
    }
}
