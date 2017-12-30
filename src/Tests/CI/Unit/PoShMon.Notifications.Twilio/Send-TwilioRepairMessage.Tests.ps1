$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\..\..\') -Resolve
Remove-Module PoShMon -ErrorAction SilentlyContinue
Import-Module (Join-Path $rootPath -ChildPath "PoShMon.psd1")

Describe "Send-TwilioRepairMessage" {
	It "Should send a Twilio Repair message" {

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

		$testRepairOutput = @(
								@{
									"SectionHeader" = "Sample Repair"
									"RepairResult" = "Repair Performed"
								}
							)

		Mock -CommandName New-ShortRepairMessageSubject -ModuleName PoShMon -Verifiable -MockWith {
			return
		}
		Mock -CommandName New-ShortRepairMessageBody -ModuleName PoShMon -Verifiable -MockWith {
			return 
		}
		Mock -CommandName Send-TwilioMessage -ModuleName PoShMon -Verifiable -MockWith {
			return 
		}

		$actual = Send-RepairNotifications $poShMonConfiguration $poShMonConfiguration.Notifications.Sinks $testRepairOutput

		Assert-VerifiableMock
	}

}
