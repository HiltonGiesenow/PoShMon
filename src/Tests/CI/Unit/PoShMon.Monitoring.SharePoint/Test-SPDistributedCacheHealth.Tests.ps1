$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\..\..\') -Resolve
Remove-Module PoShMon -ErrorAction SilentlyContinue
Import-Module (Join-Path $rootPath -ChildPath "PoShMon.psd1")

Describe "Test-SPDistributedCacheHealth" {
    InModuleScope PoShMon {

        class SPDistributedCacheMock {
            [object]$Server
            [object]$Status

            SPDistributedCacheMock ([string]$NewServerDisplayName, [string]$NewStatusValue) {
                $this.Server = [pscustomobject]@{DisplayName=$NewServerDisplayName};
                $this.Status = [pscustomobject]@{Value=$NewStatusValue};
            }
        }

        It "Should return a matching output structure" {
    
            Mock -CommandName Invoke-RemoteCommand -ModuleName PoShMon -MockWith {
                return @(
                    [SPDistributedCacheMock]::new('Server1', 'Online')
                )
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                }   

            $actual = Test-SPDistributedCacheHealth $poShMonConfiguration

            $headerKeyCount = 2

            $actual.Keys.Count | Should Be 5
            $actual.ContainsKey("NoIssuesFound") | Should Be $true
            $actual.ContainsKey("OutputHeaders") | Should Be $true
            $actual.ContainsKey("OutputValues") | Should Be $true
            $actual.ContainsKey("SectionHeader") | Should Be $true
            $actual.ContainsKey("ElapsedTime") | Should Be $true
            $headers = $actual.OutputHeaders
            $headers.Keys.Count | Should Be $headerKeyCount
            $actual.OutputValues[0].Server | Should Be 'Server1'
            $actual.OutputValues[0].Status | Should Be 'Online'
            $actual.OutputValues[0].Status | Should Be 'Online'
            $actual.OutputValues[0].Highlight.Count | Should Be 0
            #$values1 = $actual.OutputValues[0]
            #$values1.Keys.Count | Should Be ($headerKeyCount+1)
            #$values1.ContainsKey("Server") | Should Be $true
            #$values1.ContainsKey("Status") | Should Be $true
            #$values1.ContainsKey("Highlight") | Should Be $true
        }

        It "Should write the expected Verbose output" {
    
            Mock -CommandName Invoke-RemoteCommand -ModuleName PoShMon -Verifiable -MockWith {
                return @(
                    [SPDistributedCacheMock]::new('Server1', 'Online')
                )
            }

            $poShMonConfiguration = New-PoShMonConfiguration {}

            $actual = Test-SPDistributedCacheHealth $poShMonConfiguration -Verbose
            $output = $($actual = Test-SPDistributedCacheHealth $poShMonConfiguration -Verbose) 4>&1

            $output.Count | Should Be 3
            $output[0].ToString() | Should Be "Initiating 'Distributed Cache Status' Test..."
            $output[1].ToString() | Should Be "`tServer1 : Online"
            $output[2].ToString() | Should Be "Complete 'Distributed Cache Status' Test, Issues Found: No"
        }

        It "Should write the expected Warning output" {
    
            Mock -CommandName Invoke-RemoteCommand -ModuleName PoShMon -Verifiable -MockWith {
                return @(
                    [SPDistributedCacheMock]::new('Server1', 'Online'),
                    [SPDistributedCacheMock]::new('Server2', 'Offline')
                )
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General -ServerNames 'Server1'
                            OperatingSystem
                        }

            $actual = Test-SPDistributedCacheHealth $poShMonConfiguration
            $output = $($actual = Test-SPDistributedCacheHealth $poShMonConfiguration) 3>&1

            $output.Count | Should Be 1
            $output[0].ToString() | Should Be "`tServer2 is listed as Offline"
        }

        It "Should not warn on all server are online" {

            Mock -CommandName Invoke-RemoteCommand -ModuleName PoShMon -Verifiable -MockWith {
                return @(
                    [SPDistributedCacheMock]::new('Server1', 'Online')
                )
            }

            $poShMonConfiguration = New-PoShMonConfiguration {}

            $actual = Test-SPDistributedCacheHealth $poShMonConfiguration
        
            Assert-VerifiableMocks

            $actual.NoIssuesFound | Should Be $true

            $actual.OutputValues.Highlight.Count | Should Be 0
        }

        It "Should warn on servers being offline" {

            Mock -CommandName Invoke-RemoteCommand -ModuleName PoShMon -Verifiable -MockWith {
                return @(
                    [SPDistributedCacheMock]::new('Server1', 'Online'),
                    [SPDistributedCacheMock]::new('Server2', 'Offline')
                )
            }

            $poShMonConfiguration = New-PoShMonConfiguration {}

            $actual = Test-SPDistributedCacheHealth $poShMonConfiguration -WarningAction SilentlyContinue
        
            Assert-VerifiableMocks

            $actual.NoIssuesFound | Should Be $false

            $actual.OutputValues[0].Highlight.Count | Should Be 0
            $actual.OutputValues[1].Highlight.Count | Should Be 1
            $actual.OutputValues[1].Highlight[0] | Should Be 'Status'
        }
    }
}