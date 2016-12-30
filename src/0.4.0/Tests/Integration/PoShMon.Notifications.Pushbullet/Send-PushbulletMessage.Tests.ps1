$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\..\') -Resolve
Import-Module (Join-Path $rootPath -ChildPath "PoShMon.psd1") -Verbose
$sutFileName = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests", "")
$sutFilePath = Join-Path $rootPath -ChildPath "Functions\PoShMon.Notifications.Pushbullet\$sutFileName" 
. $sutFilePath

Describe "Send-PushbulletMessage" {
    It "Should return a the correct html for given test output" {

        $pushbulletConfig = Get-Content -Raw -Path ([Environment]::GetFolderPath("MyDocuments") + "\pushbulletconfig.json") | ConvertFrom-Json

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

        $actual = Send-PushbulletMessage $poShMonConfiguration $poShMonConfiguration.Notifications.Sinks "All" $testMonitoringOutput $totalElapsedTime -Verbose

    }

}