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

        class SPCacheHostMock {
            [object]$HostName
            [object]$Status

            SPCacheHostMock ([string]$NewHostName, [string]$NewStatusValue) {
                $this.HostName = $NewHostName;
                $this.Status = $NewStatusValue;
            }
        }

        It "Should return a matching output structure" {
    
            Mock -CommandName Invoke-RemoteCommand -ModuleName PoShMon -MockWith {
                return @(
                    [SPDistributedCacheMock]::new('Server1', 'Online')
                )
            }

            Mock -CommandName Get-SPCacheHostInfo -MockWith {
                return [SPCacheHostMock]::new('Server1.network.local', 'Up')
            }

            $poShMonConfiguration = New-PoShMonConfiguration {}   

            $actual = Test-SPDistributedCacheHealth $poShMonConfiguration

            $headerKeyCount = 3

            $actual.Keys.Count | Should Be 5
            $actual.ContainsKey("NoIssuesFound") | Should Be $true
            $actual.ContainsKey("OutputHeaders") | Should Be $true
            $actual.ContainsKey("OutputValues") | Should Be $true
            $actual.ContainsKey("SectionHeader") | Should Be $true
            $actual.ContainsKey("ElapsedTime") | Should Be $true
            $headers = $actual.OutputHeaders
            $headers.Keys.Count | Should Be $headerKeyCount
            $actual.OutputValues[0].Server | Should Be 'Server1'
            $actual.OutputValues[0].SharePointStatus | Should Be 'Online'
            $actual.OutputValues[0].CacheClusterMemberStatus | Should Be 'Up'
            $actual.OutputValues[0].Highlight.Count | Should Be 0
        }

        It "Should write the expected Verbose output" {
    
            Mock -CommandName Invoke-RemoteCommand -ModuleName PoShMon -Verifiable -MockWith {
                return @(
                    [SPDistributedCacheMock]::new('Server1', 'Online')
                )
            }

            Mock -CommandName Get-SPCacheHostInfo -MockWith {
                return [SPCacheHostMock]::new('Server1.network.local', 'Up')
            }

            $poShMonConfiguration = New-PoShMonConfiguration {}

            $actual = Test-SPDistributedCacheHealth $poShMonConfiguration -Verbose
            $output = $($actual = Test-SPDistributedCacheHealth $poShMonConfiguration -Verbose) 4>&1

            $output.Count | Should Be 4
            $output[0].ToString() | Should Be "Initiating 'Distributed Cache Status' Test..."
            $output[1].ToString() | Should Be "`tServer1 : Online"
            $output[2].ToString() | Should Be "`t`tServer1.network.local : Up"
            $output[3].ToString() | Should Be "Complete 'Distributed Cache Status' Test, Issues Found: No"
        }

        It "Should write the expected Warning output - One Server Offline, Both Up" {
    
            Mock -CommandName Invoke-RemoteCommand -ModuleName PoShMon -Verifiable -MockWith {
                return @(
                    [SPDistributedCacheMock]::new('Server1', 'Online'),
                    [SPDistributedCacheMock]::new('Server2', 'Offline')
                )
            }

            Mock -CommandName Get-SPCacheHostInfo -MockWith {
                return @(
                    [SPCacheHostMock]::new('Server1.network.local', 'Up'),
                    [SPCacheHostMock]::new('Server2.network.local', 'Up')
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

        It "Should write the expected Warning output - One Server Offline and Down" {
    
            Mock -CommandName Invoke-RemoteCommand -ModuleName PoShMon -Verifiable -MockWith {
                return @(
                    [SPDistributedCacheMock]::new('Server1', 'Online'),
                    [SPDistributedCacheMock]::new('Server2', 'Offline')
                )
            }

            Mock -CommandName Get-SPCacheHostInfo -MockWith {
                return @(
                    [SPCacheHostMock]::new('Server1.network.local', 'Up'),
                    [SPCacheHostMock]::new('Server2.network.local', 'Down')
                )
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General -ServerNames 'Server1'
                            OperatingSystem
                        }

            $actual = Test-SPDistributedCacheHealth $poShMonConfiguration
            $output = $($actual = Test-SPDistributedCacheHealth $poShMonConfiguration) 3>&1

            $output.Count | Should Be 2
            $output[0].ToString() | Should Be "`tServer2 is listed as Offline"
            $output[1].ToString() | Should Be "`tServer2.network.local is listed as Down"
        }

        It "Should write the expected Warning output - Both Online, one Down" {
    
            Mock -CommandName Invoke-RemoteCommand -ModuleName PoShMon -Verifiable -MockWith {
                return @(
                    [SPDistributedCacheMock]::new('Server1', 'Online'),
                    [SPDistributedCacheMock]::new('Server2', 'Online')
                )
            }

            Mock -CommandName Get-SPCacheHostInfo -MockWith {
                return @(
                    [SPCacheHostMock]::new('Server1.network.local', 'Up'),
                    [SPCacheHostMock]::new('Server2.network.local', 'Down')
                )
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General -ServerNames 'Server1'
                            OperatingSystem
                        }

            $actual = Test-SPDistributedCacheHealth $poShMonConfiguration
            $output = $($actual = Test-SPDistributedCacheHealth $poShMonConfiguration) 3>&1

            $output.Count | Should Be 1
            $output[0].ToString() | Should Be "`tServer2.network.local is listed as Down"
        }

        It "Should write the expected Warning output - No Cluster Members" {
    
            Mock -CommandName Invoke-RemoteCommand -ModuleName PoShMon -Verifiable -MockWith {
                return @(
                    [SPDistributedCacheMock]::new('Server1', 'Online'),
                    [SPDistributedCacheMock]::new('Server2', 'Online')
                )
            }

            Mock -CommandName Get-SPCacheHostInfo -MockWith {
                return @()
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General -ServerNames 'Server1'
                            OperatingSystem
                        }

            $actual = Test-SPDistributedCacheHealth $poShMonConfiguration
            $output = $($actual = Test-SPDistributedCacheHealth $poShMonConfiguration) 3>&1

            $output.Count | Should Be 2
            $output[0].ToString() | Should Be "`tCache cluster entry not found for Server1"
            $output[1].ToString() | Should Be "`tCache cluster entry not found for Server2"
        }

        It "Should not warn on all server are online" {

            Mock -CommandName Invoke-RemoteCommand -ModuleName PoShMon -Verifiable -MockWith {
                return @(
                    [SPDistributedCacheMock]::new('Server1', 'Online')
                )
            }

            Mock -CommandName Get-SPCacheHostInfo -MockWith {
                return @(
                    [SPCacheHostMock]::new('Server1.network.local', 'Up')
                )
            }

            $poShMonConfiguration = New-PoShMonConfiguration {}

            $actual = Test-SPDistributedCacheHealth $poShMonConfiguration
        
            Assert-VerifiableMock

            $actual.NoIssuesFound | Should Be $true

            $actual.OutputValues.Highlight.Count | Should Be 0
        }

        It "Should warn on servers being Offline" {

            Mock -CommandName Invoke-RemoteCommand -ModuleName PoShMon -Verifiable -MockWith {
                return @(
                    [SPDistributedCacheMock]::new('Server1', 'Online'),
                    [SPDistributedCacheMock]::new('Server2', 'Offline')
                )
            }

            Mock -CommandName Get-SPCacheHostInfo -MockWith {
                return @(
                    [SPCacheHostMock]::new('Server1.network.local', 'Up'),
                    [SPCacheHostMock]::new('Server2.network.local', 'Up')
                )
            }

            $poShMonConfiguration = New-PoShMonConfiguration {}

            $actual = Test-SPDistributedCacheHealth $poShMonConfiguration -WarningAction SilentlyContinue
        
            Assert-VerifiableMock

            $actual.NoIssuesFound | Should Be $false

            $actual.OutputValues[0].Highlight.Count | Should Be 0
            $actual.OutputValues[1].Highlight.Count | Should Be 1
            $actual.OutputValues[1].Highlight[0] | Should Be 'SharePointStatus'
        }

        It "Should warn on servers being Offline and Down" {

            Mock -CommandName Invoke-RemoteCommand -ModuleName PoShMon -Verifiable -MockWith {
                return @(
                    [SPDistributedCacheMock]::new('Server1', 'Online'),
                    [SPDistributedCacheMock]::new('Server2', 'Offline')
                )
            }

            Mock -CommandName Get-SPCacheHostInfo -MockWith {
                return @(
                    [SPCacheHostMock]::new('Server1.network.local', 'Up'),
                    [SPCacheHostMock]::new('Server2.network.local', 'Down')
                )
            }

            $poShMonConfiguration = New-PoShMonConfiguration {}

            $actual = Test-SPDistributedCacheHealth $poShMonConfiguration -WarningAction SilentlyContinue
        
            Assert-VerifiableMock

            $actual.NoIssuesFound | Should Be $false

            $actual.OutputValues[0].Highlight.Count | Should Be 0
            $actual.OutputValues[1].Highlight.Count | Should Be 2
            $actual.OutputValues[1].Highlight[0] | Should Be 'SharePointStatus'
            $actual.OutputValues[1].Highlight[1] | Should Be 'CacheClusterMemberStatus'
        }

        It "Should warn on all servers being Offline" {

            Mock -CommandName Invoke-RemoteCommand -ModuleName PoShMon -Verifiable -MockWith {
                return @(
                    [SPDistributedCacheMock]::new('Server1', 'Offline'),
                    [SPDistributedCacheMock]::new('Server2', 'Offline')
                )
            }

            Mock -CommandName Get-SPCacheHostInfo -MockWith {
                return @(
                    [SPCacheHostMock]::new('Server1.network.local', 'Up'),
                    [SPCacheHostMock]::new('Server2.network.local', 'Down')
                )
            }

            $poShMonConfiguration = New-PoShMonConfiguration {}

            $actual = Test-SPDistributedCacheHealth $poShMonConfiguration
            $output = $($actual = Test-SPDistributedCacheHealth $poShMonConfiguration) 3>&1

            $output.Count | Should Be 5
            $output[0].ToString() | Should Be "`tNo healthy servers found in cache cluster from Get-SPServiceInstance"
            $output[1].ToString() | Should Be "`tServer1 is listed as Offline"
            $output[2].ToString() | Should Be "`tCache cluster entry not found for Server1"
            $output[3].ToString() | Should Be "`tServer2 is listed as Offline"
            $output[4].ToString() | Should Be "`tCache cluster entry not found for Server2"
        }
    }
}