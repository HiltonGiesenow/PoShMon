$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\..\..\') -Resolve
Remove-Module PoShMon -ErrorAction SilentlyContinue
Import-Module (Join-Path $rootPath -ChildPath "PoShMon.psd1")

Describe "Test-SPServerStatus" {
    InModuleScope PoShMon {

        class SPServerMock {
            [string]$DisplayName
            [string]$Status
            [bool]$NeedsUpgrade
            [string]$Role

            SPServerMock ([string]$NewDisplayName, [string]$NewStatus, [bool]$NewNeedsUpgrade, [string]$NewRole) {
                $this.DisplayName = $NewDisplayName
                $this.Status = $NewStatus
                $this.NeedsUpgrade = $NewNeedsUpgrade
                $this.Role = $NewRole
            }
        }

        It "Should return a matching output structure" {

            Mock -CommandName Get-SPServerForRemoteServer -ModuleName PoShMon -MockWith {
                return [SPServerMock]::new($ServerName, 'Online', $false, 'Application')
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                                        General -ServerNames 'Server1','Server2'
                                    }   

            $actual = Test-SPServerStatus $poShMonConfiguration

            $headerKeyCount = 4

            $actual.Keys.Count | Should Be 6
            $actual.ContainsKey("NoIssuesFound") | Should Be $true
            $actual.ContainsKey("OutputHeaders") | Should Be $true
            $actual.ContainsKey("OutputValues") | Should Be $true
            $actual.ContainsKey("SectionHeader") | Should Be $true
            $actual.ContainsKey("ElapsedTime") | Should Be $true
            $actual.ContainsKey("HeaderUrl") | Should Be $true
            $headers = $actual.OutputHeaders
            $headers.Keys.Count | Should Be $headerKeyCount
            $actual.OutputValues[1].ServerName | Should Be 'Server2'
            $actual.OutputValues[1].Role | Should Be 'Application'
            $actual.OutputValues[1].NeedsUpgrade | Should Be 'No'
            $actual.OutputValues[1].Status | Should Be 'Online'
            $actual.OutputValues[1].Highlight.Count | Should Be 0
            #$values1 = $actual.OutputValues[0]
            #$values1.Keys.Count | Should Be ($headerKeyCount + 1)
            #$values1.ContainsKey("ServerName") | Should Be $true
            #$values1.ContainsKey("Role") | Should Be $true
            #$values1.ContainsKey("NeedsUpgrade") | Should Be $true
            #$values1.ContainsKey("Status") | Should Be $true
            #$values1.ContainsKey("Highlight") | Should Be $true
        }

        It "Should write the expected Verbose output" {
    
            Mock -CommandName Get-SPServerForRemoteServer -ModuleName PoShMon -MockWith {
                return [SPServerMock]::new($ServerName, 'Online', $false, 'Application')
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                                        General -ServerNames 'Server1','Server2'
                                    }

            $actual = Test-SPServerStatus $poShMonConfiguration -Verbose
            $output = $($actual = Test-SPServerStatus $poShMonConfiguration -Verbose) 4>&1

            $output.Count | Should Be 4
            $output[0].ToString() | Should Be "Initiating 'Farm Server Status' Test..."
            $output[1].ToString() | Should Be "`tServer1 : Online : False"
            $output[2].ToString() | Should Be "`tServer2 : Online : False"
            $output[3].ToString() | Should Be "Complete 'Farm Server Status' Test, Issues Found: No"
        }

        It "Should write the expected Warning output" {
    
            Mock -CommandName Get-SPServerForRemoteServer -ModuleName PoShMon -MockWith {

                $needsUpgrade = if ($ServerName -eq 'Server2') { $true } else { $false }
                $online = if ($ServerName -eq 'Server3') { 'Offline' } else { 'Online' }
            
                return [SPServerMock]::new($ServerName, $online, $needsUpgrade, 'Application')
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                                        General -ServerNames 'Server1','Server2','Server3'
                                    }

            $actual = Test-SPServerStatus $poShMonConfiguration
            $output = $($actual = Test-SPServerStatus $poShMonConfiguration) 3>&1

            $output.Count | Should Be 2
            $output[0].ToString() | Should Be "`tServer2 is listed as Needing Upgrade"
            $output[1].ToString() | Should Be "`tServer3 is not listed as Online. Status: Offline"
        }

        It "Should return an output for each Server" {
    
            Mock -CommandName Get-SPServerForRemoteServer -ModuleName PoShMon -MockWith {
                return [SPServerMock]::new($ServerName, 'Online', $false, 'Application')
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                                        General -ServerNames 'Server1','Server2'
                                    }   

            $actual = Test-SPServerStatus $poShMonConfiguration

            $actual.OutputValues.Count | Should Be 2
        }

        It "Should warn on any component needing upgrade" {
    
            Mock -CommandName Get-SPServerForRemoteServer -ModuleName PoShMon -MockWith {

                $needsUpgrade = if ($ServerName -eq 'Server1') { $false } else { $true }
            
                return [SPServerMock]::new($ServerName, 'Online', $needsUpgrade, 'Application')
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                                        General -ServerNames 'Server1','Server2'
                                    }

            $actual = Test-SPServerStatus $poShMonConfiguration -WarningAction SilentlyContinue

            $actual.NoIssuesFound | Should Be $false

            $actual.OutputValues.Highlight.Count | Should Be 1
            $actual.OutputValues[0].Highlight.Count | Should Be 0
            $actual.OutputValues[1].Highlight.Count | Should Be 1
            $actual.OutputValues[1].Highlight[0] | Should Be 'NeedsUpgrade'
        }

       It "Should warn on any component not being Online" {
    
            Mock -CommandName Get-SPServerForRemoteServer -ModuleName PoShMon -MockWith {

                $status = if ($ServerName -eq 'Server1') { 'Online' } else { 'Something Else' }
            
                return [SPServerMock]::new($ServerName, $status, $false, 'TheRole')
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                                        General -ServerNames 'Server1','Server2'
                                    }

            $actual = Test-SPServerStatus $poShMonConfiguration -WarningAction SilentlyContinue

            $actual.NoIssuesFound | Should Be $false

            $actual.OutputValues.Highlight.Count | Should Be 1
            $actual.OutputValues[0].Highlight.Count | Should Be 0
            $actual.OutputValues[1].Highlight.Count | Should Be 1
            $actual.OutputValues[1].Highlight[0] | Should Be 'Status'
        }

       It "Should warn on any component not being Online and needing upgrade" {
    
            Mock -CommandName Get-SPServerForRemoteServer -ModuleName PoShMon -MockWith {

                $status = if ($ServerName -eq 'Server1') { 'Online' } else { 'Something Else' }
                $needsUpgrade = if ($ServerName -eq 'Server1') { $false } else { $true }
            
                return [SPServerMock]::new($ServerName, $status, $needsUpgrade, 'TheRole')
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                                        General -ServerNames 'Server1','Server2'
                                    }

            $actual = Test-SPServerStatus $poShMonConfiguration -WarningAction SilentlyContinue

            $actual.NoIssuesFound | Should Be $false

            $actual.OutputValues.Highlight.Count | Should Be 2
            $actual.OutputValues[0].Highlight.Count | Should Be 0
            $actual.OutputValues[1].Highlight.Count | Should Be 2
            $actual.OutputValues[1].Highlight[0] | Should Be 'NeedsUpgrade'
            $actual.OutputValues[1].Highlight[1] | Should Be 'Status'
        }
    }
}