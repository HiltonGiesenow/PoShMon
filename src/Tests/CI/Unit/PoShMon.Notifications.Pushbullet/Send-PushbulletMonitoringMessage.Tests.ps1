$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\..\..\') -Resolve
Remove-Module PoShMon -ErrorAction SilentlyContinue
Import-Module (Join-Path $rootPath -ChildPath "PoShMon.psd1")

$pushbulletConfigPath = [Environment]::GetFolderPath("MyDocuments") + "\pushbulletconfig.json"

if (Test-Path $pushbulletConfigPath) # only run this test if there's a config to send notifications
{
    Describe "Send-PushbulletMonitoringMessage" {
        It "Should send a Pushbullet message" {

            $pushbulletConfig = Get-Content -Raw -Path $pushbulletConfigPath | ConvertFrom-Json

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General `
                                -EnvironmentName 'SharePoint' `
                                -MinutesToScanHistory 60 `
                                -PrimaryServerName 'ZAMGNTSPAPP1' `
                                -ConfigurationName SpFarmPosh `
                                -TestsToSkip 'SPServerStatus','WindowsServiceState','SPFailingTimerJobs','SPDatabaseHealth','SPSearchHealth','SPDistributedCacheHealth','WebTests'
                            Notifications -When All {
                                Pushbullet `
                                    -AccessToken $pushbulletConfig.AccessToken `
                                    -DeviceId $pushbulletConfig.DeviceId
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

			Mock -CommandName Send-PushbulletMessage -ModuleName PoShMon -Verifiable -MockWith {
				$Subject | Should Be "[PoshMon SharePoint Monitoring Results]"
				$Body | Should Be "Grouped Test With A Long Name : issue(s) found - No `r`nUngrouped Test : issue(s) found - Yes `r`n"
			}

            $actual = Send-PushbulletMonitoringMessage $poShMonConfiguration $testMonitoringOutput $poShMonConfiguration.Notifications.Sinks "All" ([timespan]::new(1000)) $true

			Assert-VerifiableMock
        }

    }
}