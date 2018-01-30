$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\..\..\') -Resolve
Remove-Module PoShMon -ErrorAction SilentlyContinue
Import-Module (Join-Path $rootPath -ChildPath "PoShMon.psd1")

Describe "Resolve-HighCPUWhileSearchRunning" {
    InModuleScope PoShMon {

        class ContentSourceMock {
            [string]$Name
            [string]$CrawlState
        
            ContentSourceMock ([string]$NewName, [string]$NewCrawlState) {
                $this.Name = $NewName;
                $this.CrawlState = $NewCrawlState;
            }
        }

        class SearchComponentMock {
            [string]$Name
            [string]$ServerName
        
            SearchComponentMock ([string]$NewName, [string]$NewServerName) {
                $this.Name = $NewName;
                $this.ServerName = $NewServerName;
            }
        }

        It "Should not change output for non-Search activity" {

            Mock -CommandName Invoke-RemoteCommand -ModuleName PoShMon -Verifiable -MockWith {
            
                $contentSources = @(
                                    [ContentSourceMock]::new("ContentSource1", "Idle")
                                )
            
                $componentTopology = @(
                                    [SearchComponentMock]::new("IndexComponent1", "Svr123")
                                    [SearchComponentMock]::new("QueryProcessingComponent1", "Svr123")
                                )
            
                return @{
                    "ContentSources" = $contentSources;
                    "ComponentTopology" = $componentTopology
                }
            }

            $poShMonConfiguration = New-PoShMonConfiguration {}

            $testMonitoringOutput = @(
                @{
                    "SectionHeader" = "Server CPU Load Review"
                    "OutputHeaders" =[ordered]@{ 'ServerName' = 'Server Name'; 'CPULoad' = 'CPU Load (%)' }
                    "NoIssuesFound" = $false
                    "ElapsedTime" = (Get-Date).Subtract((Get-Date).AddMinutes(-1))
                    "OutputValues" = @(
                                        @{
                                            "ServerName" = "Svr123"
                                            "CPULoad" = 5
                                            "Highlight" = @()
                                        },
                                        @{
                                            "ServerName" = "Svr456"
                                            "CPULoad" = 99
                                            "Highlight" = @("CPULoad")
                                        }
                                    )
                }
                @{
                    "SectionHeader" = "Another Test Test"
                    "OutputHeaders" = @{ 'ComponentName' = 'Component'; 'State' = 'State' }
                    "NoIssuesFound" = $true
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

            $actual = Resolve-HighCPUWhileSearchRunning $poShMonConfiguration $testMonitoringOutput
        
            Assert-VerifiableMock

            $testMonitoringOutput.Count | Should Be 2
            $testMonitoringOutput[0].OutputValues[1].Highlight[0] | Should Be "CPULoad"
        }

        It "Should not change output for Search Query activity" {

            Mock -CommandName Invoke-RemoteCommand -ModuleName PoShMon -Verifiable -MockWith {
            
                $contentSources = @(
                                    [ContentSourceMock]::new("ContentSource1", "Idle")
                                )
            
                $componentTopology = @(
                                    [SearchComponentMock]::new("IndexComponent1", "Svr123")
                                    [SearchComponentMock]::new("QueryProcessingComponent1", "Svr456")
                                )
            
                return @{
                    "ContentSources" = $contentSources;
                    "ComponentTopology" = $componentTopology
                }
            }

            $poShMonConfiguration = New-PoShMonConfiguration {}

            $testMonitoringOutput = @(
                @{
                    "SectionHeader" = "Server CPU Load Review"
                    "OutputHeaders" =[ordered]@{ 'ServerName' = 'Server Name'; 'CPULoad' = 'CPU Load (%)' }
                    "NoIssuesFound" = $false
                    "ElapsedTime" = (Get-Date).Subtract((Get-Date).AddMinutes(-1))
                    "OutputValues" = @(
                                        @{
                                            "ServerName" = "Svr123"
                                            "CPULoad" = 5
                                            "Highlight" = @()
                                        },
                                        @{
                                            "ServerName" = "Svr456"
                                            "CPULoad" = 99
                                            "Highlight" = @("CPULoad")
                                        }
                                    )
                }
                @{
                    "SectionHeader" = "Another Test Test"
                    "OutputHeaders" = @{ 'ComponentName' = 'Component'; 'State' = 'State' }
                    "NoIssuesFound" = $true
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

            $actual = Resolve-HighCPUWhileSearchRunning $poShMonConfiguration $testMonitoringOutput
        
            Assert-VerifiableMock

            $testMonitoringOutput.Count | Should Be 2
            $testMonitoringOutput[0].OutputValues[1].Highlight[0] | Should Be "CPULoad"
        }

        It "Should change output for non-Query Search activity" {

            Mock -CommandName Invoke-RemoteCommand -ModuleName PoShMon -Verifiable -MockWith {
            
                $contentSources = @(
                                    [ContentSourceMock]::new("ContentSource1", "Idle")
                                )
            
                $componentTopology = @(
                                    [SearchComponentMock]::new("IndexComponent1", "Svr456")
                                    [SearchComponentMock]::new("QueryProcessingComponent1", "Svr123")
                                )
            
                return @{
                    "ContentSources" = $contentSources;
                    "ComponentTopology" = $componentTopology
                }
            }

            $poShMonConfiguration = New-PoShMonConfiguration {}

            $testMonitoringOutput = @(
                @{
                    "SectionHeader" = "Server CPU Load Review"
                    "OutputHeaders" =[ordered]@{ 'ServerName' = 'Server Name'; 'CPULoad' = 'CPU Load (%)' }
                    "NoIssuesFound" = $false
                    "ElapsedTime" = (Get-Date).Subtract((Get-Date).AddMinutes(-1))
                    "OutputValues" = @(
                                        @{
                                            "ServerName" = "Svr123"
                                            "CPULoad" = 5
                                            "Highlight" = @()
                                        },
                                        @{
                                            "ServerName" = "Svr456"
                                            "CPULoad" = 99
                                            "Highlight" = @("CPULoad")
                                        }
                                    )
                }
                @{
                    "SectionHeader" = "Another Test Test"
                    "OutputHeaders" = @{ 'ComponentName' = 'Component'; 'State' = 'State' }
                    "NoIssuesFound" = $true
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

            $actual = Resolve-HighCPUWhileSearchRunning $poShMonConfiguration $testMonitoringOutput
        
            Assert-VerifiableMock

            $testMonitoringOutput.Count | Should Be 2
            $testMonitoringOutput[0].OutputValues[1].Highlight.Count | Should Be 0
            $testMonitoringOutput[0].NoIssuesFound | Should Be $true
        }
    }
}