$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\..\..\') -Resolve
Remove-Module PoShMon -ErrorAction SilentlyContinue
Import-Module (Join-Path $rootPath -ChildPath "PoShMon.psd1")

Describe "Invoke-OSMonitoring" {
    It "Should invoke OS monitoring" {

        $poShMonConfiguration = New-PoShMonConfiguration {
                        General `
                            -EnvironmentName 'OS Base Test' `
                            -MinutesToScanHistory 60 `
                            -ServerNames 'Server01','Server02' `
                            -ConfigurationName SpFarmPosh `
                            -TestsToSkip 'Memory'
                        Notifications -When All {
                            Email -ToAddress "someone@email.com" -FromAddress "all@jones.com" -SmtpServer "smtp.company.com"
                            Pushbullet -AccessToken "TestAccessToken" -DeviceId "TestDeviceID"
                            O365Teams -TeamsWebHookUrl "http://teams.office.com/theapi"
                        }               
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
            Write-Verbose "Tests Run:"
            $TestOutputValues | % { Write-Verbose "`t$($_.SectionHeader)" }
            return
        }

        $actual = Invoke-OSMonitoring $poShMonConfiguration -Verbose

        Assert-VerifiableMock
    }
}

Describe "Invoke-OSMonitoring2" {
    It "Should work with a minimal configuration" -Skip {

        $poShMonConfiguration = New-PoShMonConfiguration {}
        
		$actual = Invoke-OSMonitoring $poShMonConfiguration -Verbose
		
		0 | Should Not Be $null 
    }
}
