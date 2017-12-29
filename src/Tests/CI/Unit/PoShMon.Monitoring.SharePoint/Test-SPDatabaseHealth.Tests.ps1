$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\..\..\') -Resolve
Remove-Module PoShMon -ErrorAction SilentlyContinue
Import-Module (Join-Path $rootPath -ChildPath "PoShMon.psd1")

Describe "Test-SPDatabaseHealth" {
    InModuleScope PoShMon {

        class SPDatabaseMock {
            [string]$DisplayName
            [string]$ApplicationName
            [bool]$NeedsUpgrade
            [UInt64]$DiskSizeRequired
        
            SPDatabaseMock ([string]$NewDisplayName, [string]$NewApplicationName, [bool]$NewNeedsUpgrade, [UInt64]$NewDiskSizeRequired) {
                $this.DisplayName = $NewDisplayName;
                $this.ApplicationName = $NewApplicationName;
                $this.NeedsUpgrade = $NewNeedsUpgrade;
                $this.DiskSizeRequired = $NewDiskSizeRequired;
            }
        }

        It "Should return a matching output structure" {
    
            Mock -CommandName Invoke-RemoteCommand -ModuleName PoShMon -MockWith {
                return @(
                    [SPDatabaseMock]::new('Database1', 'Application1', $false, [UInt64]50GB)
                )
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                }

            $actual = Test-SPDatabaseHealth $poShMonConfiguration

            $headerKeyCount = 3

            $actual.Keys.Count | Should Be 7
            $actual.ContainsKey("NoIssuesFound") | Should Be $true
            $actual.ContainsKey("OutputHeaders") | Should Be $true
            $actual.ContainsKey("OutputValues") | Should Be $true
            $actual.ContainsKey("SectionHeader") | Should Be $true
            $actual.ContainsKey("ElapsedTime") | Should Be $true
            $actual.ContainsKey("LinkColumn") | Should Be $true
            $actual.ContainsKey("HeaderUrl") | Should Be $true
            $headers = $actual.OutputHeaders
            $headers.Keys.Count | Should Be $headerKeyCount
            $values1 = $actual.OutputValues[0]
            $actual.OutputValues[0].DatabaseName | Should Be 'Database1'
            $actual.OutputValues[0].NeedsUpgrade | Should Be 'No'
            $actual.OutputValues[0].Size | Should Be '50.00'
            $actual.OutputValues[0].Highlight.Count | Should Be 0
            #$values1.Keys.Count | Should Be ($headerKeyCount+1)
            #$values1.ContainsKey("DatabaseName") | Should Be $true
            #$values1.ContainsKey("NeedsUpgrade") | Should Be $true
            #$values1.ContainsKey("Size") | Should Be $true
            #$values1.ContainsKey("Highlight") | Should Be $true
        }

        It "Should write the expected Verbose output" {
    
            Mock -CommandName Invoke-RemoteCommand -ModuleName PoShMon -Verifiable -MockWith {
                return @(
                    [SPDatabaseMock]::new('Database1', 'Application1', $false, [UInt64]50GB),
                    [SPDatabaseMock]::new('Database2', 'Application1', $false, [UInt64]4GB)
                )
            }

            $poShMonConfiguration = New-PoShMonConfiguration {}

            $actual = Test-SPDatabaseHealth $poShMonConfiguration -Verbose
            $output = $($actual = Test-SPDatabaseHealth $poShMonConfiguration -Verbose) 4>&1

            $output.Count | Should Be 4
            $output[0].ToString() | Should Be "Initiating 'Database Status' Test..."
            $output[1].ToString() | Should Be "`tDatabase1 : No : 50.00 GB"
            $output[2].ToString() | Should Be "`tDatabase2 : No : 4.00 GB"
            $output[3].ToString() | Should Be "Complete 'Database Status' Test, Issues Found: No"

            Assert-VerifiableMock
        }

        It "Should write the expected Warning output" {
    
            Mock -CommandName Invoke-RemoteCommand -ModuleName PoShMon -Verifiable -MockWith {
                return @(
                    [SPDatabaseMock]::new('Database1', 'Application1', $false, [UInt64]50GB),
                    [SPDatabaseMock]::new('Database2', 'Application1', $true, [UInt64]4GB)
                )
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General -ServerNames 'Server1'
                            OperatingSystem
                        }

            $actual = Test-SPDatabaseHealth $poShMonConfiguration
            $output = $($actual = Test-SPDatabaseHealth $poShMonConfiguration) 3>&1

            $output.Count | Should Be 1
            $output[0].ToString() | Should Be "`tDatabase2 (Application1) is listed as Needing Upgrade"
        }

        It "Should not warn on databases that are all fine" {

            Mock -CommandName Invoke-RemoteCommand -ModuleName PoShMon -Verifiable -MockWith {
                return @(
                    [SPDatabaseMock]::new('Database1', 'Application1', $false, [UInt64]50GB),
                    [SPDatabaseMock]::new('Database2', 'Application1', $false, [UInt64]4GB)
                )
            }

            $poShMonConfiguration = New-PoShMonConfiguration {}

            $actual = Test-SPDatabaseHealth $poShMonConfiguration
        
            Assert-VerifiableMock

            $actual.NoIssuesFound | Should Be $true

            $actual.OutputValues.Highlight.Count | Should Be 0
        }

        It "Should warn on databases that are need upgrade" {

            Mock -CommandName Invoke-RemoteCommand -ModuleName PoShMon -Verifiable -MockWith {
                return @(
                    [SPDatabaseMock]::new('Database1', 'Application1', $false, [UInt64]50GB),
                    [SPDatabaseMock]::new('Database2', 'Application1', $true, [UInt64]4GB)
                )
            }

            $poShMonConfiguration = New-PoShMonConfiguration {}

            $actual = Test-SPDatabaseHealth $poShMonConfiguration -WarningAction SilentlyContinue
        
            Assert-VerifiableMock

            $actual.NoIssuesFound | Should Be $false

            $actual.OutputValues[0].Highlight.Count | Should Be 0
            $actual.OutputValues[1].Highlight.Count | Should Be 1
            $actual.OutputValues[1].Highlight[0] | Should Be 'NeedsUpgrade'
        }
    }
}