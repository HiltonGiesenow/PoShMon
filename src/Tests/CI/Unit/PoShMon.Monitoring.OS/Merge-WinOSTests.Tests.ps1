$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\..\..\') -Resolve
Remove-Module PoShMon -ErrorAction SilentlyContinue
Import-Module (Join-Path $rootPath -ChildPath "PoShMon.psd1")

Describe "Merge-WinOSTests" {
    It "Should return a matching output structure" {

        $poShMonConfiguration = New-PoShMonConfiguration {
                    General -EnvironmentName 'SharePoint' -PrimaryServerName 'Server1'
                }

        $testMonitoringOutput = [System.Collections.ArrayList]@(
            @{
                "SectionHeader" = "Server CPU Load Review"
                "OutputHeaders" = [ordered]@{ 'ServerName' = 'Server Name'; 'CPULoad' = 'CPU Load (%)' }
                "NoIssuesFound" = $true
                "ElapsedTime" = (Get-Date).Subtract((Get-Date).AddMinutes(-1))
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
                "ElapsedTime" = (Get-Date).Subtract((Get-Date).AddMinutes(-1))
                "OutputValues" = @(
                                    @{
                                        "ServerName" = "Server1"
                                        "TotalMemory" = "7.93"
                                        "FreeMemory" = "2.71 (35%)"
                                        "Highlight" = @()
                                    },
                                    @{
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
}