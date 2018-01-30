$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\..\..\') -Resolve
Remove-Module PoShMon -ErrorAction SilentlyContinue
Import-Module (Join-Path $rootPath -ChildPath "PoShMon.psd1")

Describe "Send-TwilioExceptionMessage" {
	It "Should send a Twilio Exception message" {

		$poShMonConfiguration = New-PoShMonConfiguration {
						General `
							-EnvironmentName 'SharePoint' `
							-MinutesToScanHistory 60 `
							-PrimaryServerName 'ZAMGNTSPAPP1' `
							-ConfigurationName SpFarmPosh `
							-TestsToSkip 'SPServerStatus','WindowsServiceState','SPFailingTimerJobs','SPDatabaseHealth','SPSearchHealth','SPDistributedCacheHealth','WebTests'
						Notifications -When All {
							Twilio `
								-SID "TestSID" `
								-Token "TestToken" `
								-FromAddress "TestFromAddress" `
								-ToAddress "TestToAddress"
						}               
					}

		Mock -CommandName New-ShortExceptionMessageSubject -ModuleName PoShMon -Verifiable -MockWith {
			return 
		}
		Mock -CommandName New-ShortExceptionMessageBody -ModuleName PoShMon -Verifiable -MockWith {
			return 
		}
		Mock -CommandName Send-TwilioMessage -ModuleName PoShMon -Verifiable -MockWith {
			return 
		}

		$actual = Send-ExceptionNotifications $poShMonConfiguration ([System.Exception]::new("Test Exception")) "Monitoring"

		Assert-VerifiableMock
	}

}
