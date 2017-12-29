$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\..\..\') -Resolve
Remove-Module PoShMon -ErrorAction SilentlyContinue
Import-Module (Join-Path $rootPath -ChildPath "PoShMon.psd1")

Describe "Test-Memory" {
    InModuleScope PoShMon {

        class ServerMemoryMock {
            [string]$PSComputerName
            [UInt64]$TotalVisibleMemorySize
            [UInt64]$FreePhysicalMemory

            ServerMemoryMock ([string]$NewPSComputerName, [UInt64]$NewTotalVisibleMemorySize, [UInt64]$NewFreePhysicalMemory) {
                $this.PSComputerName = $NewPSComputerName;
                $this.TotalVisibleMemorySize = $NewTotalVisibleMemorySize;
                $this.FreePhysicalMemory = $NewFreePhysicalMemory;
            }
        }

        #It "Should throw an exception if no OperatingSystem configuration is set" {
        #
        #    $poShMonConfiguration = New-PoShMonConfiguration { }
        #
        #    { Test-Memory $poShMonConfiguration } | Should throw
        #}

        It "Should return a matching output structure" {
    
            Mock -CommandName Get-WmiObject -MockWith {
                return [ServerMemoryMock]::new($ComputerName, 8312456, 2837196)
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General -ServerNames 'Server1'
                            OperatingSystem
                        }

            $actual = Test-Memory $poShMonConfiguration

            $actual.Keys.Count | Should Be 5
            $actual.ContainsKey("NoIssuesFound") | Should Be $true
            $actual.ContainsKey("OutputHeaders") | Should Be $true
            $actual.ContainsKey("OutputValues") | Should Be $true
            $actual.ContainsKey("SectionHeader") | Should Be $true
            $actual.ContainsKey("ElapsedTime") | Should Be $true
            $headers = $actual.OutputHeaders
            $headers.Keys.Count | Should Be 3
            #$values1 = $actual.OutputValues[0]
            #$values1.Keys.Count | Should Be 4
            #$values1.ContainsKey("ServerName") | Should Be $true
            #$values1.ContainsKey("TotalMemory") | Should Be $true
            #$values1.ContainsKey("FreeMemory") | Should Be $true
            #$values1.ContainsKey("Highlight") | Should Be $true
            $actual.OutputValues[0].ServerName | Should Be "Server1"
            $actual.OutputValues[0].TotalMemory | Should Be "7.93"
            $actual.OutputValues[0].FreeMemory | Should Be "2.71 (34%)"
            $actual.OutputValues[0].Highlight.Count | Should Be 0
        }

        It "Should write the expected Verbose output" {
    
            Mock -CommandName Get-WmiObject -MockWith {
                return [ServerMemoryMock]::new($ComputerName, 8312456, 2837196)
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General -ServerNames 'Server1'
                            OperatingSystem
                        }

            $actual = Test-Memory $poShMonConfiguration -Verbose
            $output = $($actual = Test-Memory $poShMonConfiguration -Verbose) 4>&1

            $output.Count | Should Be 3
            $output[0].ToString() | Should Be "Initiating 'Memory Review' Test..."
            $output[1].ToString() | Should Be "`tServer1 : 7.93 : 2.71 (34%)"
            $output[2].ToString() | Should Be "Complete 'Memory Review' Test, Issues Found: No"
        }

        It "Should write the expected Warning output" {
    
            Mock -CommandName Get-WmiObject -MockWith {
                return [ServerMemoryMock]::new($ComputerName, 8312456, 300000)
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General -ServerNames 'Server1'
                            OperatingSystem
                        }

            $actual = Test-Memory $poShMonConfiguration
            $output = $($actual = Test-Memory $poShMonConfiguration) 3>&1

            $output.Count | Should Be 1
            $output[0].ToString() | Should Be "`t`tFree memory (4%) is below variance threshold (10)"
        }

        It "Should not warn on space above threshold" {

            Mock -CommandName Get-WmiObject -MockWith {
                return [ServerMemoryMock]::new($ComputerName, 8312456, 2837196)
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General -ServerNames 'localhost'
                            OperatingSystem
                        }

            $actual = Test-Memory $poShMonConfiguration -WarningAction SilentlyContinue
        
            $actual.NoIssuesFound | Should Be $true

            $actual.OutputValues.GroupOutputValues.Highlight.Count | Should Be 0
        }

        It "Should warn on space below threshold" {
        
            Mock -CommandName Get-WmiObject -MockWith {
                return [ServerMemoryMock]::new('TheServer', 8312456, 10000)
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General -ServerNames 'TheServer'
                            OperatingSystem
                        }

            $actual = Test-Memory $poShMonConfiguration -WarningAction SilentlyContinue
        
            $actual.NoIssuesFound | Should Be $false

            $actual.OutputValues.Highlight.Count | Should Be 1
            $actual.OutputValues.Highlight | Should Be 'FreeMemory'
        }

        It "Should use the configuration threshold properly" {
        
            $memory = 8312456*0.5

            Mock -CommandName Get-WmiObject -MockWith {
                return [ServerMemoryMock]::new($ComputerName, 8312456, $memory)
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General -ServerNames 'localhost'
                            OperatingSystem -FreeMemoryThreshold 51
                        }

            $actual = Test-Memory $poShMonConfiguration -WarningAction SilentlyContinue
        
            $actual.NoIssuesFound | Should Be $false

            $actual.OutputValues.Highlight.Count | Should Be 1
            $actual.OutputValues.Highlight | Should Be 'FreeMemory'
        }
    }
}