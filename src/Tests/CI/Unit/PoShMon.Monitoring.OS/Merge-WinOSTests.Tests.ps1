$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\..\..\') -Resolve
Remove-Module PoShMon -ErrorAction SilentlyContinue
Import-Module (Join-Path $rootPath -ChildPath "PoShMon.psd1")

Describe "Merge-WinOSTests" {
    It "Should return a matching output structure" {

        $currentTime = Get-Date

        $poShMonConfiguration = New-PoShMonConfiguration {
                    General -EnvironmentName 'SharePoint' -PrimaryServerName 'Server1'
                }

        $testMonitoringOutput = [System.Collections.ArrayList]@(
            @{
                "SectionHeader" = "Server CPU Load Review"
                "OutputHeaders" = [ordered]@{ 'ServerName' = 'Server Name'; 'CPULoad' = 'CPU Load (%)' }
                "NoIssuesFound" = $true
                "ElapsedTime" = $currentTime.Subtract($currentTime.AddMinutes(-1))
                "OutputValues" = @(
                                    [pscustomobject]@{
                                        "ServerName" = "Server1"
                                        "CPULoad" = "5%"
                                    },
                                    [pscustomobject]@{
                                        "ServerName" = "Server2"
                                        "CPULoad" = "13%"
                                    }
                                )
            }
            @{
                "SectionHeader" = "Memory Review"
                "OutputHeaders" = [ordered]@{ 'ServerName' = 'Server Name'; 'TotalMemory' = 'Total Memory (GB)'; 'FreeMemory' = 'Free Memory (GB) (%)' }
                "NoIssuesFound" = $false
                "ElapsedTime" = $currentTime.Subtract($currentTime.AddMinutes(-1))
                "OutputValues" = @(
                                    [pscustomobject]@{
                                        "ServerName" = "Server1"
                                        "TotalMemory" = "7.93"
                                        "FreeMemory" = "2.71 (35%)"
                                        "Highlight" = @()
                                    },
                                    [pscustomobject]@{
                                        "ServerName" = "Server2"
                                        "TotalMemory" = "7.93"
                                        "FreeMemory" = "0.91 (3%)"
                                        "Highlight" = @("FreeMemory")
                                    }
                                )
            }
            @{
                "SectionHeader" = "Another Test"
                "OutputHeaders" = [ordered]@{ 'ComponentName' = 'Component'; 'State' = 'State' }
                "NoIssuesFound" = $false
                "ElapsedTime" = $currentTime.Subtract($currentTime.AddMinutes(-1))
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

        $actual = Merge-WinOSTests $poShMonConfiguration $testMonitoringOutput

        $actual[0].Keys.Count | Should Be 5
        $actual[0].ContainsKey("NoIssuesFound") | Should Be $true
        $actual[0].ContainsKey("OutputHeaders") | Should Be $true
        $actual[0].ContainsKey("OutputValues") | Should Be $true
        $actual[0].ContainsKey("SectionHeader") | Should Be $true
        $actual[0]["SectionHeader"] | Should Be "Server Overview"
        $actual[0].ContainsKey("ElapsedTime") | Should Be $true
        $headers = $actual[0].OutputHeaders
        $headers.Keys.Count | Should Be 3
        $actual[0].OutputValues[1].ServerName | Should Be 'Server2'
        $actual[0].OutputValues[1].CPULoad | Should Be '13%'
        $actual[0].OutputValues[1].Memory | Should Be '0.91 / 7.93 (3%)'
        $actual[0].OutputValues[1].Highlight.Count | Should Be 1

    }

    It "Should merge all matching tests" {

        $poShMonConfiguration = New-PoShMonConfiguration {
                    General -EnvironmentName 'SharePoint' -PrimaryServerName 'Server1'
                }

        $currentTime = Get-Date
        $lastBootTime = $currentTime.AddDays(-1)

        $testMonitoringOutput = [System.Collections.ArrayList]@(
            @{
                "SectionHeader" = "Server CPU Load Review"
                "OutputHeaders" = [ordered]@{ 'ServerName' = 'Server Name'; 'CPULoad' = 'CPU Load (%)' }
                "NoIssuesFound" = $true
                "ElapsedTime" = $currentTime.Subtract($currentTime.AddMinutes(-1))
                "OutputValues" = @(
                                    [pscustomobject]@{
                                        "ServerName" = "Server1"
                                        "CPULoad" = "5%"
                                    },
                                    [pscustomobject]@{
                                        "ServerName" = "Server2"
                                        "CPULoad" = "13%"
                                    }
                                )
            }
            @{
                "SectionHeader" = "Memory Review"
                "OutputHeaders" = [ordered]@{ 'ServerName' = 'Server Name'; 'TotalMemory' = 'Total Memory (GB)'; 'FreeMemory' = 'Free Memory (GB) (%)' }
                "NoIssuesFound" = $false
                "ElapsedTime" = $currentTime.Subtract($currentTime.AddMinutes(-2))
                "OutputValues" = @(
                                    [pscustomobject]@{
                                        "ServerName" = "Server1"
                                        "TotalMemory" = "7.93"
                                        "FreeMemory" = "2.71 (35%)"
                                        "Highlight" = @()
                                    },
                                    [pscustomobject]@{
                                        "ServerName" = "Server2"
                                        "TotalMemory" = "7.93"
                                        "FreeMemory" = "0.91 (3%)"
                                        "Highlight" = @("FreeMemory")
                                    }
                                )
            }
            @{
                "SectionHeader" = "Server Clock Review"
                "OutputHeaders" = [ordered]@{ 'ServerName' = 'Server Name'; 'CurrentTime' = 'Current Time'; 'LastBootUptime' = 'Last Boot Time'; }
                "NoIssuesFound" = $false
                "ElapsedTime" = $currentTime.Subtract($currentTime.AddMinutes(-3))
                "OutputValues" = @(
                                    [pscustomobject]@{
                                        "ServerName" = "Server1"
                                        "CurrentTime" = $currentTime.ToString()
                                        "LastBootUptime" = $lastBootTime.ToString()
                                        "Highlight" = @()
                                    },
                                    [pscustomobject]@{
                                        "ServerName" = "Server2"
                                        "CurrentTime" = $currentTime.ToString()
                                        "LastBootUptime" = $lastBootTime.ToString()
                                        "Highlight" = @("CurrentTime", "LastBootUptime")
                                    }
                                )
            }
            @{
                "SectionHeader" = "Another Test"
                "OutputHeaders" = [ordered]@{ 'ComponentName' = 'Component'; 'State' = 'State' }
                "NoIssuesFound" = $false
                "ElapsedTime" = $currentTime.Subtract($currentTime.AddMinutes(-1))
                "OutputValues" = @(
                                    [pscustomobject]@{
                                        "ComponentName" = 123
                                        "State" = "State 1"
                                    },
                                    [pscustomobject]@{
                                        "ComponentName" = 456
                                        "State" = "State 2"
                                    }
                                )
            }
        )

        $actual = Merge-WinOSTests $poShMonConfiguration $testMonitoringOutput

        $actual.Count | Should Be 2
        $actual[0].Keys.Count | Should Be 5
        $actual[0].ContainsKey("NoIssuesFound") | Should Be $true
        $actual[0].ContainsKey("OutputHeaders") | Should Be $true
        $actual[0].ContainsKey("OutputValues") | Should Be $true
        $actual[0].ContainsKey("SectionHeader") | Should Be $true
        $actual[0]["SectionHeader"] | Should Be "Server Overview"
        $actual[0].ContainsKey("ElapsedTime") | Should Be $true
        $headers = $actual[0].OutputHeaders
        $headers.Keys.Count | Should Be 5
        $actual[0].NoIssuesFound  | Should Be $false
        $actual[0].OutputValues[1].ServerName | Should Be 'Server2'
        $actual[0].OutputValues[1].CPULoad | Should Be '13%'
        $actual[0].OutputValues[1].Memory | Should Be '0.91 / 7.93 (3%)'
        $actual[0].OutputValues[1].CurrentTime | Should Be $currentTime.ToString()
        $actual[0].OutputValues[1].LastBootUptime | Should Be $lastBootTime.ToString()
        $actual[0].OutputValues[1].Highlight.Count | Should Be 3
        $actual[0].OutputValues[1].Highlight[0] | Should Be "Memory"
        $actual[0].OutputValues[1].Highlight[1] | Should Be "CurrentTime"
        $actual[0].OutputValues[1].Highlight[2] | Should Be "LastBootUptime"
        $actual[0].ElapsedTime | Should Be ([timespan]::new(0, 6, 0))
        $actual[1]["SectionHeader"] | Should Be "Another Test"
    }

    It "Should show NoIssuesFound if all Tests are fine" {

        $poShMonConfiguration = New-PoShMonConfiguration {
                    General -EnvironmentName 'SharePoint' -PrimaryServerName 'Server1'
                }

        $currentTime = Get-Date
        $lastBootTime = $currentTime.AddDays(-1)

        $testMonitoringOutput = [System.Collections.ArrayList]@(
            @{
                "SectionHeader" = "Server CPU Load Review"
                "OutputHeaders" = [ordered]@{ 'ServerName' = 'Server Name'; 'CPULoad' = 'CPU Load (%)' }
                "NoIssuesFound" = $true
                "ElapsedTime" = $currentTime.Subtract($currentTime.AddMinutes(-1))
                "OutputValues" = @(
                                    [pscustomobject]@{
                                        "ServerName" = "Server1"
                                        "CPULoad" = "5%"
                                         "Highlight" = @()
                                    },
                                    [pscustomobject]@{
                                        "ServerName" = "Server2"
                                        "CPULoad" = "13%"
                                        "Highlight" = @()
                                    }
                                )
            }
            @{
                "SectionHeader" = "Memory Review"
                "OutputHeaders" = [ordered]@{ 'ServerName' = 'Server Name'; 'TotalMemory' = 'Total Memory (GB)'; 'FreeMemory' = 'Free Memory (GB) (%)' }
                "NoIssuesFound" = $true
                "ElapsedTime" = $currentTime.Subtract($currentTime.AddMinutes(-2))
                "OutputValues" = @(
                                    [pscustomobject]@{
                                        "ServerName" = "Server1"
                                        "TotalMemory" = "7.93"
                                        "FreeMemory" = "2.71 (35%)"
                                        "Highlight" = @()
                                    },
                                    [pscustomobject]@{
                                        "ServerName" = "Server2"
                                        "TotalMemory" = "7.93"
                                        "FreeMemory" = "0.91 (3%)"
                                        "Highlight" = @()
                                    }
                                )
            }
            @{
                "SectionHeader" = "Server Clock Review"
                "OutputHeaders" = [ordered]@{ 'ServerName' = 'Server Name'; 'CurrentTime' = 'Current Time'; 'LastBootUptime' = 'Last Boot Time'; }
                "NoIssuesFound" = $true
                "ElapsedTime" = $currentTime.Subtract($currentTime.AddMinutes(-3))
                "OutputValues" = @(
                                    [pscustomobject]@{
                                        "ServerName" = "Server1"
                                        "CurrentTime" = $currentTime.ToString()
                                        "LastBootUptime" = $lastBootTime.ToString()
                                        "Highlight" = @()
                                    },
                                    [pscustomobject]@{
                                        "ServerName" = "Server2"
                                        "CurrentTime" = $currentTime.ToString()
                                        "LastBootUptime" = $lastBootTime.ToString()
                                        "Highlight" = @()
                                    }
                                )
            }
            @{
                "SectionHeader" = "Another Test"
                "OutputHeaders" = [ordered]@{ 'ComponentName' = 'Component'; 'State' = 'State' }
                "NoIssuesFound" = $false
                "ElapsedTime" = $currentTime.Subtract($currentTime.AddMinutes(-1))
                "OutputValues" = @(
                                    [pscustomobject]@{
                                        "ComponentName" = 123
                                        "State" = "State 1"
                                    },
                                    [pscustomobject]@{
                                        "ComponentName" = 456
                                        "State" = "State 2"
                                    }
                                )
            }
        )

        $actual = Merge-WinOSTests $poShMonConfiguration $testMonitoringOutput

        $actual.Count | Should Be 2
        $actual[0].Keys.Count | Should Be 5
        $actual[0].ContainsKey("NoIssuesFound") | Should Be $true
        $actual[0].ContainsKey("OutputHeaders") | Should Be $true
        $actual[0].ContainsKey("OutputValues") | Should Be $true
        $actual[0].ContainsKey("SectionHeader") | Should Be $true
        $actual[0]["SectionHeader"] | Should Be "Server Overview"
        $actual[0].ContainsKey("ElapsedTime") | Should Be $true
        $headers = $actual[0].OutputHeaders
        $headers.Keys.Count | Should Be 5
        $actual[0].NoIssuesFound  | Should Be $true
        $actual[0].OutputValues[1].ServerName | Should Be 'Server2'
        $actual[0].OutputValues[1].CPULoad | Should Be '13%'
        $actual[0].OutputValues[1].Memory | Should Be '0.91 / 7.93 (3%)'
        $actual[0].OutputValues[1].CurrentTime | Should Be $currentTime.ToString()
        $actual[0].OutputValues[1].LastBootUptime | Should Be $lastBootTime.ToString()
        $actual[0].OutputValues[1].Highlight.Count | Should Be 0
        $actual[0].ElapsedTime | Should Be ([timespan]::new(0, 6, 0))
        $actual[1]["SectionHeader"] | Should Be "Another Test"
    }

    It "Should not merge if only one valid test appears" {

        $poShMonConfiguration = New-PoShMonConfiguration {
                    General -EnvironmentName 'SharePoint' -PrimaryServerName 'Server1'
                }

        $currentTime = Get-Date
        $lastBootTime = $currentTime.AddDays(-1)

        $testMonitoringOutput = [System.Collections.ArrayList]@(
            @{
                "SectionHeader" = "Memory Review"
                "OutputHeaders" = [ordered]@{ 'ServerName' = 'Server Name'; 'TotalMemory' = 'Total Memory (GB)'; 'FreeMemory' = 'Free Memory (GB) (%)' }
                "NoIssuesFound" = $true
                "ElapsedTime" = $currentTime.Subtract($currentTime.AddMinutes(-20))
                "OutputValues" = @(
                                    [pscustomobject]@{
                                        "ServerName" = "Server1"
                                        "TotalMemory" = "7.93"
                                        "FreeMemory" = "2.71 (35%)"
                                        "Highlight" = @()
                                    },
                                    [pscustomobject]@{
                                        "ServerName" = "Server2"
                                        "TotalMemory" = "7.93"
                                        "FreeMemory" = "0.91 (3%)"
                                        "Highlight" = @()
                                    }
                                )
            }
            @{
                "SectionHeader" = "Another Test"
                "OutputHeaders" = [ordered]@{ 'ComponentName' = 'Component'; 'State' = 'State' }
                "NoIssuesFound" = $false
                "ElapsedTime" = $currentTime.Subtract($currentTime.AddMinutes(-1))
                "OutputValues" = @(
                                    [pscustomobject]@{
                                        "ComponentName" = 123
                                        "State" = "State 1"
                                    },
                                    [pscustomobject]@{
                                        "ComponentName" = 456
                                        "State" = "State 2"
                                    }
                                )
            }
        )

        $actual = Merge-WinOSTests $poShMonConfiguration $testMonitoringOutput

        $actual.Count | Should Be 2
        $actual[0].Keys.Count | Should Be 5
        $actual[0].ContainsKey("NoIssuesFound") | Should Be $true
        $actual[0].ContainsKey("OutputHeaders") | Should Be $true
        $actual[0].ContainsKey("OutputValues") | Should Be $true
        $actual[0].ContainsKey("SectionHeader") | Should Be $true
        $actual[0]["SectionHeader"] | Should Be "Memory Review"
        $actual[0].ContainsKey("ElapsedTime") | Should Be $true
        $headers = $actual[0].OutputHeaders
        $headers.Keys.Count | Should Be 3
        $actual[0].NoIssuesFound  | Should Be $true
        $actual[0].OutputValues[0].ServerName | Should Be 'Server1'
        $actual[0].OutputValues[0].TotalMemory | Should Be "7.93"
        $actual[0].OutputValues[0].FreeMemory | Should Be "2.71 (35%)"
        $actual[0].OutputValues[0].Highlight.Count | Should Be 0
        $actual[0].ElapsedTime | Should Be ([timespan]::new(0, 20, 0))
        $actual[1]["SectionHeader"] | Should Be "Another Test"
    }
}