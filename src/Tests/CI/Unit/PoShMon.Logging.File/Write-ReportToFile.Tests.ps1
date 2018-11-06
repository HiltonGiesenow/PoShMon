$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\..\..\') -Resolve
Remove-Module PoShMon -ErrorAction SilentlyContinue
Import-Module (Join-Path $rootPath -ChildPath "PoShMon.psd1")

Describe "Write-PoShMonHtmlReport" {

	InModuleScope PoShMon {

		Mock -CommandName New-HtmlBody -Verifiable -ModuleName PoShMon -MockWith {
			return "test html"
		}

		Mock -CommandName Out-File -Verifiable -MockWith {
			return;
		}

		It "Should pick up the Global Configuration object if one is not passed in" {

			$PoShMonConfigurationGlobal = New-PoShMonConfiguration { General -EnvironmentName "Global Test" }

			$testMonitoringOutput = @()
			Write-PoShMonHtmlReport -PoShMonOutputValues $testMonitoringOutput -OutputFilePath "C:\Temp\PoShMonReport.html"

			Assert-MockCalled -CommandName New-HtmlBody -ParameterFilter { $PoShMonConfiguration.General.EnvironmentName -eq "Global Test" }
			Assert-MockCalled -CommandName Out-File
		}

		It "Should pick up the Global TimeSpan object if one is not passed in" {

			$PoShMonConfigurationGlobal = New-PoShMonConfiguration { General -EnvironmentName "Global Test" }
			$Global:PoShMon_TotalElapsedTime = New-TimeSpan -Minutes 1 -Seconds 2

			$testMonitoringOutput = @()
			Write-PoShMonHtmlReport -PoShMonOutputValues $testMonitoringOutput -OutputFilePath "C:\Temp\PoShMonReport.html"

			Assert-MockCalled -CommandName New-HtmlBody -ParameterFilter { $TotalElapsedTime.TotalMilliseconds -eq 62000 }
			Assert-MockCalled -CommandName Out-File
		}

		It "Should use the provided Configuration object if one is passed in" {

			$PoShMonConfigurationTest = New-PoShMonConfiguration { General -EnvironmentName "Instance Test" }
			$PoShMonConfigurationGlobal = New-PoShMonConfiguration { General -EnvironmentName "Global Test" }

			$testMonitoringOutput = @()
			Write-PoShMonHtmlReport -PoShMonOutputValues $testMonitoringOutput -OutputFilePath "C:\Temp\PoShMonReport.html" -PoShMonConfiguration $PoShMonConfigurationTest

			Assert-MockCalled -CommandName New-HtmlBody -ParameterFilter { $PoShMonConfiguration.General.EnvironmentName -eq "Instance Test" }
			Assert-MockCalled -CommandName Out-File
		}

		It "Should use the provided TimeSpan object if one is passed in" {

			$PoShMonConfigurationGlobal = New-PoShMonConfiguration { General -EnvironmentName "Global Test" }
			$Global:PoShMon_TotalElapsedTime = New-TimeSpan -Minutes 1 -Seconds 2
			$TestTimeSpan = New-TimeSpan -Minutes 2 -Seconds 3

			$testMonitoringOutput = @()
			Write-PoShMonHtmlReport -PoShMonOutputValues $testMonitoringOutput -OutputFilePath "C:\Temp\PoShMonReport.html" -TotalElapsedTime $TestTimeSpan

			Assert-MockCalled -CommandName New-HtmlBody -ParameterFilter { $TotalElapsedTime.TotalMilliseconds -eq 123000 }
			Assert-MockCalled -CommandName Out-File
		}

		It "Passes in NoClobber correctly" {

			$PoShMonConfigurationGlobal = New-PoShMonConfiguration { General -EnvironmentName "Global Test" }
			$Global:PoShMon_TotalElapsedTime = New-TimeSpan -Minutes 1 -Seconds 2
			$TestTimeSpan = New-TimeSpan -Minutes 2 -Seconds 3

			$testMonitoringOutput = @()
			Write-PoShMonHtmlReport -PoShMonOutputValues $testMonitoringOutput -OutputFilePath "C:\Temp\PoShMonReport.html" -TotalElapsedTime $TestTimeSpan

			Assert-MockCalled -CommandName Out-File -ParameterFilter { $NoClobber -eq $true }

		}

		It "Passes in NoClobber correctly for FALSE" {

			$PoShMonConfigurationGlobal = New-PoShMonConfiguration { General -EnvironmentName "Global Test" }
			$Global:PoShMon_TotalElapsedTime = New-TimeSpan -Minutes 1 -Seconds 2
			$TestTimeSpan = New-TimeSpan -Minutes 2 -Seconds 3

			$testMonitoringOutput = @()
			Write-PoShMonHtmlReport -PoShMonOutputValues $testMonitoringOutput -OutputFilePath "C:\Temp\PoShMonReport.html" -TotalElapsedTime $TestTimeSpan -OverwriteFileIfExists:$true

			Assert-MockCalled -CommandName Out-File -ParameterFilter { $NoClobber -eq $false }
		}

		It "Writes All Output in One Go" {

			$PoShMonConfigurationGlobal = New-PoShMonConfiguration { General -EnvironmentName "Global Test" }
			$Global:PoShMon_TotalElapsedTime = New-TimeSpan -Minutes 1 -Seconds 2
			$TestTimeSpan = New-TimeSpan -Minutes 2 -Seconds 3

			$testMonitoringOutput = @(
                @{
                    "SectionHeader" = "Grouped Test"
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
                                            "ComponentName" = 123
                                            "State" = "State 1"
                                        },
                                        @{
                                            "ComponentName" = 456
                                            "State" = "State 2"
                                        }
                                    )
                }
			)
			
			Write-PoShMonHtmlReport -PoShMonOutputValues $testMonitoringOutput -OutputFilePath "C:\Temp\PoShMonReport.html" -TotalElapsedTime $TestTimeSpan -OverwriteFileIfExists:$true

			Assert-MockCalled -CommandName Out-File -ParameterFilter { $NoClobber -eq $false }
		}
	}
}
