$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\..\..\') -Resolve
Remove-Module PoShMon -ErrorAction SilentlyContinue
Import-Module (Join-Path $rootPath -ChildPath "PoShMon.psd1")

Describe "Send-TwilioMonitoringMessage" {
	It "Should send a Twilio Monitoring message" {

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

					$testMonitoringOutput = @(
						@{
							"SectionHeader" = "Grouped Test With A Long Name"
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
													"Component" = 123
													"State" = "State 1"
												},
												@{
													"Component" = 456
													"State" = "State 2"
												}
											)
						}
					)

		$totalElapsedTime = (Get-Date).Subtract((Get-Date).AddMinutes(-3))

		Mock -CommandName New-ShortMessageSubject -ModuleName PoShMon -Verifiable -MockWith {
			$ShowIssueCount | Should Be $false
			return
		}
		Mock -CommandName New-ShortMessageBody -ModuleName PoShMon -Verifiable -MockWith {
			return 
		}
		Mock -CommandName Send-TwilioMessage -ModuleName PoShMon -Verifiable -MockWith {
			return 
		}

		$actual = Send-MonitoringNotifications $poShMonConfiguration $poShMonConfiguration.Notifications.Sinks "All" $testMonitoringOutput $totalElapsedTime

		Assert-VerifiableMock
	}

}
