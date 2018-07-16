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
			$testMonitoringOutput | Write-PoShMonHtmlReport -OutputFilePath "C:\Temp\PoShMonReport.html"

			Assert-MockCalled -CommandName New-HtmlBody -ParameterFilter { $PoShMonConfiguration.General.EnvironmentName -eq "Global Test" }
			Assert-MockCalled -CommandName Out-File
		}

		It "Should pick up the Global TimeSpan object if one is not passed in" {

			$PoShMonConfigurationGlobal = New-PoShMonConfiguration { General -EnvironmentName "Global Test" }
			$Global:TotalElapsedPoShMonTime = New-TimeSpan -Minutes 1 -Seconds 2

			$testMonitoringOutput = @()
			$testMonitoringOutput | Write-PoShMonHtmlReport -OutputFilePath "C:\Temp\PoShMonReport.html"

			Assert-MockCalled -CommandName New-HtmlBody -ParameterFilter { $TotalElapsedTime.TotalMilliseconds -eq 62000 }
			Assert-MockCalled -CommandName Out-File
		}

		It "Should use the provided Configuration object if one is passed in" {

			$PoShMonConfigurationTest = New-PoShMonConfiguration { General -EnvironmentName "Instance Test" }
			$PoShMonConfigurationGlobal = New-PoShMonConfiguration { General -EnvironmentName "Global Test" }

			$testMonitoringOutput = @()
			$testMonitoringOutput | Write-PoShMonHtmlReport -OutputFilePath "C:\Temp\PoShMonReport.html" -PoShMonConfiguration $PoShMonConfigurationTest

			Assert-MockCalled -CommandName New-HtmlBody -ParameterFilter { $PoShMonConfiguration.General.EnvironmentName -eq "Instance Test" }
			Assert-MockCalled -CommandName Out-File
		}

		It "Should use the provided TimeSpan object if one is passed in" {

			$PoShMonConfigurationGlobal = New-PoShMonConfiguration { General -EnvironmentName "Global Test" }
			$Global:TotalElapsedPoShMonTime = New-TimeSpan -Minutes 1 -Seconds 2
			$TestTimeSpan = New-TimeSpan -Minutes 2 -Seconds 3

			$testMonitoringOutput = @()
			$testMonitoringOutput | Write-PoShMonHtmlReport -OutputFilePath "C:\Temp\PoShMonReport.html" -TotalElapsedTime $TestTimeSpan

			Assert-MockCalled -CommandName New-HtmlBody -ParameterFilter { $TotalElapsedTime.TotalMilliseconds -eq 123000 }
			Assert-MockCalled -CommandName Out-File
		}
	}
}
