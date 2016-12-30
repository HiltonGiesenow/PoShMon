$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\..\') -Resolve
Import-Module (Join-Path $rootPath -ChildPath "PoShMon.psd1") -Verbose
$sutFileName = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests", "")
$sutFilePath = Join-Path $rootPath -ChildPath "Functions\PoShMon.Notifications.Email\$sutFileName" 
. $sutFilePath

Describe "Get-EmailOutput" {
    It "Should return a the correct html for given test output" {

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

<#        Mock -CommandName Get-WmiObject -MockWith {
            return [DiskMock]::new('C:', 3, "", [UInt64]255465615360, [UInt64]61145096192, "MyCDrive")
        }
#>
        $actual = Get-EmailOutput $testMonitoringOutput -Verbose

        $actual | Should Be '<p><h1>Grouped Test Ungrouped Test  ( Seconds)</h1><table border="1"><thead><tr><th align="left" colspan="4"><h2>Server 1</h2></th></tr><tr><th align="left"></th><th align="left"></th><th align="left"></th><th align="left"></th></tr></thead><tbody><tr><td valign="top" align="left">Message 1</td><td valign="top" align="right">123</td><td valign="top" align="left"></td><td valign="top" align="left"></td></tr><tr><td valign="top" align="left">Message 2</td><td valign="top" align="right">456</td><td valign="top" align="left"></td><td valign="top" align="left"></td></tr></tbody><thead><tr><th align="left" colspan="4"><h2>Server 2</h2></th></tr><tr><th align="left"></th><th align="left"></th><th align="left"></th><th align="left"></th></tr></thead><tbody><tr><td valign="top" align="left">Message 3</td><td valign="top" align="right">789</td><td valign="top" align="left"></td><td valign="top" align="left"></td></tr></tbody><thead><tr><th align="left" colspan="4"><h2></h2></th></tr><tr><th align="left"></th><th align="left"></th><th align="left"></th><th align="left"></th></tr></thead><tbody></tbody><thead><tr><th align="left" colspan="4"><h2></h2></th></tr><tr><th align="left"></th><th align="left"></th><th align="left"></th><th align="left"></th></tr></thead><tbody></tbody></table>'
    }

}