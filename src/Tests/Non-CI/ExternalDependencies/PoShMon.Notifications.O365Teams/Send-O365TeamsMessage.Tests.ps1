$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\..\..\') -Resolve
Remove-Module PoShMon -ErrorAction SilentlyContinue
Import-Module (Join-Path $rootPath -ChildPath "PoShMon.psd1")

$o365TeamsConfigPath = [Environment]::GetFolderPath("MyDocuments") + "\o365TeamsConfig.json"

if (Test-Path $o365TeamsConfigPath) # only run this test if there's a config to send notifications
{
    Describe "Send-O365TeamsMessage" {
        It "Should send an O365 Teams message" {

            $o365TeamsConfig = Get-Content -Raw -Path $o365TeamsConfigPath | ConvertFrom-Json

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General `
                                -EnvironmentName 'SharePoint' `
                                -MinutesToScanHistory 60 `
                                -PrimaryServerName 'ZAMGNTSPAPP1' `
                                -ConfigurationName SpFarmPosh `
                                -TestsToSkip 'SPServerStatus','WindowsServiceState','SPFailingTimerJobs','SPDatabaseHealth','SPSearchHealth','SPDistributedCacheHealth','WebTests'
                            Notifications -When All {
                                O365Teams -TeamsWebHookUrl $o365TeamsConfig.TeamsWebHookUrl
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

            $actual = Send-O365TeamsMessage $poShMonConfiguration $poShMonConfiguration.Notifications.Sinks "Test Subject" "Test Body"
        }
    }
}