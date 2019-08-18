$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\..\..\') -Resolve
Remove-Module PoShMon -ErrorAction SilentlyContinue
Import-Module (Join-Path $rootPath -ChildPath "PoShMon.psd1")

Describe "Invoke-SPMonitoring" {
    It "Should invoke SP monitoring" {

        $poShMonConfiguration = New-PoShMonConfiguration {
                        General `
                            -EnvironmentName 'SharePoint' `
                            -MinutesToScanHistory 60 `
                            -PrimaryServerName 'AppServer01' `
                            -ConfigurationName SpFarmPosh `
                            -TestsToSkip 'SPServerStatus','SPDatabaseHealth','SPSearchHealth','SPDistributedCacheHealth'
                        Notifications -When All {
                            Email -ToAddress "someone@email.com" -FromAddress "all@jones.com" -SmtpServer "smtp.company.com"
                            Pushbullet -AccessToken "TestAccessToken" -DeviceId "TestDeviceID"
                            O365Teams -TeamsWebHookUrl "http://teams.office.com/theapi"
                        }               
                    }

        Mock -CommandName Get-ServersInSPFarm -ModuleName PoShMon -Verifiable -MockWith {
            return "Server1","Server2","Server3"
        }

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

        Mock -CommandName Get-SPFarmVersion -ModuleName PoShMon -Verifiable -MockWith {
            return @(
                        [pscustomobject]@{
                            Major = "16" #2016
                            Minor = "0"
                            Build = "1234"
                            Revision = "1000"
                        }
            )
        }

        #Mock -CommandName Get-PSSession -Verifiable -MockWith {
        #    return $null
        #}

        $actual = Invoke-SPMonitoring $poShMonConfiguration -Verbose

        Assert-VerifiableMock
    }
}
