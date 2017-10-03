$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\') -Resolve
Remove-Module PoShMon -ErrorAction SilentlyContinue
Import-Module (Join-Path $rootPath -ChildPath "PoShMon.psd1")

Describe "Invoke-OperationValidationFrameworkScan-Clear" {
    It "Should be clear for no failures" {

        $poShMonConfiguration = New-PoShMonConfiguration {
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
                "NoIssuesFound" = $true
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

        $sink = @{}

        Invoke-OperationValidationFrameworkScan -PoShMonConfiguration $poShMonConfiguration -TestOutputValues $testMonitoringOutput -Critical $true -OperationValidationFrameworkNotificationSink $sink
    }
}

Describe "Invoke-OperationValidationFrameworkScan-FailureSet" {

    It "Should fail any PoShMon failures" {

        $poShMonConfiguration = New-PoShMonConfiguration {
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
                                        "ComponentName" = 123
                                        "State" = "State 1"
                                        "Highlight" = @("State")
                                    },
                                    @{
                                        "ComponentName" = 456
                                        "State" = "State 2"
                                    }
                                )
            }
        )

        $sink = @{}

        Invoke-OperationValidationFrameworkScan -PoShMonConfiguration $poShMonConfiguration -TestOutputValues $testMonitoringOutput -Critical $true -OperationValidationFrameworkNotificationSink $sink
    }
}