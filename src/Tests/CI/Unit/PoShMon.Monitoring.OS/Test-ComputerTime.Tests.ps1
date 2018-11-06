$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\..\..\') -Resolve
Remove-Module PoShMon -ErrorAction SilentlyContinue
Import-Module (Join-Path $rootPath -ChildPath "PoShMon.psd1")

Describe "Test-ComputerTime" {
    InModuleScope PoShMon {

    class ServerTimeMock {
    [string]$PSComputerName
    [datetime]$DateTime
    [datetime]$LocalDateTime
    [datetime]$LastBootUptime
    [int]$Year
    [int]$Month
    [int]$Day
    [int]$Hour
    [int]$Minute
    [int]$Second

    ServerTimeMock ([string]$NewPSComputerName, [datetime]$NewDateTime, [datetime]$NewLastBootUptime) {
        $this.PSComputerName = $NewPSComputerName;
        $this.DateTime = $NewDateTime
        $this.LocalDateTime = $NewDateTime
        $this.LastBootUptime = $NewLastBootUptime
    }

    [datetime] ConvertToDateTime([datetime]$something) {
        return $something
    }
}

        #It "Should throw an exception if no OperatingSystem configuration is set" {
        #
        #    $poShMonConfiguration = New-PoShMonConfiguration { }
        #
        #    { Test-ComputerTime $poShMonConfiguration } | Should throw
        #}
    
        It "Should return a matching output structure" {

            Mock -ModuleName PoShMon Get-WmiObject {
                return [ServerTimeMock]::new('Server1', [datetime]::new(2017, 1, 1, 10, 15, 0), [datetime]::new(2017, 1, 1, 10, 15, 0))
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General -ServerNames 'Server1'
                            OperatingSystem
                        }

            $actual = Test-ComputerTime $poShMonConfiguration

            $actual.Keys.Count | Should Be 5
            $actual.ContainsKey("NoIssuesFound") | Should Be $true
            $actual.ContainsKey("OutputHeaders") | Should Be $true
            $actual.ContainsKey("OutputValues") | Should Be $true
            $actual.ContainsKey("SectionHeader") | Should Be $true
            $actual.ContainsKey("ElapsedTime") | Should Be $true
            $headers = $actual.OutputHeaders
            $headers.Keys.Count | Should Be 3
            #$values1 = $actual.OutputValues[0]
            #$values1.Keys.Count | Should Be 3
            $actual.OutputValues[0].ServerName | Should Be 'Server1'
            $actual.OutputValues[0].CurrentTime | Should Be ([datetime]::new(2017, 1, 1, 10, 15, 0)).ToString()
            $actual.OutputValues[0].LastBootUptime | Should Be ([datetime]::new(2017, 1, 1, 10, 15, 0)).ToString()
            $actual.OutputValues[0].Highlight[0] | Should Be 'CurrentTime'
        }

        It "Should write the expected Verbose output" {
    
            Mock -CommandName Get-WmiObject -MockWith {
                return [ServerTimeMock]::new('Server1', [datetime]::new(2017, 1, 1, 10, 15, 0), [datetime]::new(2016, 1, 1, 10, 15, 0))
            }

            Mock -CommandName Get-Date -MockWith {
                Return [datetime]::new(2017, 1, 1, 10, 15, 0)
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General -ServerNames 'Server1'
                            OperatingSystem
                        }
        
            $actual = Test-ComputerTime $poShMonConfiguration -Verbose
            $output = $($actual = Test-ComputerTime $poShMonConfiguration -Verbose) 4>&1

            $output.Count | Should Be 3
            $output[0].ToString() | Should Be "Initiating 'Server Clock Review' Test..."
            $output[1].ToString() | Should Be ("`tServer1: " + [datetime]::new(2016, 1, 1, 10, 15, 0).ToShortTimeString())
            $output[2].ToString() | Should Be "Complete 'Server Clock Review' Test, Issues Found: No"

        }

        It "Should write the expected Warning output for time difference" {
    
            Mock -CommandName Get-WmiObject -MockWith {
                return @(
                    [ServerTimeMock]::new('Server1', [datetime]::new(2017, 1, 1, 10, 09, 0), [datetime]::new(2016, 1, 1, 10, 09, 0))
                )
            }

            Mock -CommandName Get-Date -MockWith {
                Return [datetime]::new(2017, 1, 1, 10, 15, 0)
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General -ServerNames 'Server1'
                            OperatingSystem
                        }
        
            $actual = Test-ComputerTime $poShMonConfiguration
            $output = $($actual = Test-ComputerTime $poShMonConfiguration) 3>&1

            $output.Count | Should Be 1
            $output[0].ToString() | Should Be "`tDifference (6) is above variance threshold minutes (1)"
        }

        It "Should write the expected Warning output for recent reboot" {
    
            Mock -CommandName Get-WmiObject -MockWith {
                return @(
                    [ServerTimeMock]::new('Server1', [datetime]::new(2017, 1, 1, 10, 09, 0), [datetime]::new(2017, 1, 1, 10, 08, 0))
                )
            }

            Mock -CommandName Get-Date -MockWith {
                Return [datetime]::new(2017, 1, 1, 10, 09, 0)
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General -ServerNames 'Server1'
                            OperatingSystem
                        }
        
            $actual = Test-ComputerTime $poShMonConfiguration
            $output = $($actual = Test-ComputerTime $poShMonConfiguration) 3>&1

            $output.Count | Should Be 1
            $output[0].ToString() | Should Be "`tLastBootUptime (01/01/2017 10:08:00) is within the last 15 minutes"
        }

        It "Should warn on different server time (to local PoShMon machine)" {

            Mock -CommandName Get-WmiObject -MockWith {
                return @(
                    [ServerTimeMock]::new('Server1', (Get-Date -Year 2017 -Month 1 -Day 1 -Hour 10 -Minute 15).AddMinutes(-6), [datetime]::new(2016, 1, 1, 10, 15, 0))
                )
            }

            Mock -CommandName Get-Date -MockWith {
                Return [datetime]::new(2017, 1, 1, 10, 15, 0)
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General -ServerNames 'Server1'
                            OperatingSystem
                        }

            $actual = Test-ComputerTime $poShMonConfiguration -WarningAction SilentlyContinue

            $actual.NoIssuesFound | Should Be $false

            $actual.OutputValues.Highlight.Count | Should Be 1
            $actual.OutputValues.Highlight | Should Be "CurrentTime"
        }

        It "Should not warn on matching server times" {

            Mock -CommandName Get-WmiObject -MockWith {
                return @(
                    [ServerTimeMock]::new('Server1', [datetime]::new(2017, 1, 1, 10, 15, 0), [datetime]::new(2016, 1, 1, 10, 15, 0))
                    [ServerTimeMock]::new('Server2', [datetime]::new(2017, 1, 1, 10, 15, 0), [datetime]::new(2016, 1, 1, 10, 15, 0))
                    [ServerTimeMock]::new('Server3', [datetime]::new(2017, 1, 1, 10, 15, 0), [datetime]::new(2016, 1, 1, 10, 15, 0))
                )
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General -ServerNames 'Server1'
                            OperatingSystem
                        }

            $actual = Test-ComputerTime $poShMonConfiguration

            $actual.NoIssuesFound | Should Be $true

            $actual.OutputValues.Highlight.Count | Should Be 0
        }

        It "Should not warn on server time differences within default threshold" {

            Mock -CommandName Get-WmiObject -MockWith {
                return @(
                    [ServerTimeMock]::new('Server1', [datetime]::new(2017, 1, 1, 10, 15, 0), [datetime]::new(2016, 1, 1, 10, 15, 0))
                    [ServerTimeMock]::new('Server2', [datetime]::new(2017, 1, 1, 10, 14, 30), [datetime]::new(2016, 1, 1, 10, 15, 0))
                    [ServerTimeMock]::new('Server3', [datetime]::new(2017, 1, 1, 10, 15, 0), [datetime]::new(2016, 1, 1, 10, 15, 0))
                )
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General -ServerNames 'Server1'
                            OperatingSystem
                        }

            $actual = Test-ComputerTime $poShMonConfiguration

            $actual.NoIssuesFound | Should Be $true

            $actual.OutputValues.Highlight.Count | Should Be 0
        }

         It "Should warn on server times with differences above default threshold" {

            Mock -CommandName Get-WmiObject -MockWith {
                return @(
                    [ServerTimeMock]::new('Server1', [datetime]::new(2017, 1, 1, 10, 15, 0), [datetime]::new(2016, 1, 1, 10, 15, 0))
                    [ServerTimeMock]::new('Server2', [datetime]::new(2017, 1, 1, 10, 12, 0), [datetime]::new(2016, 1, 1, 10, 15, 0))
                    [ServerTimeMock]::new('Server3', [datetime]::new(2017, 1, 1, 10, 15, 0), [datetime]::new(2016, 1, 1, 10, 15, 0))
                )
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General -ServerNames 'Server1'
                            OperatingSystem
                        }

            $actual = Test-ComputerTime $poShMonConfiguration -WarningAction SilentlyContinue

            $actual.NoIssuesFound | Should Be $false

            $actual.OutputValues.Highlight.Count | Should Be 3
            $actual.OutputValues.Highlight[0] | Should Be "CurrentTime"
        }

        It "Should not warn on server time differences within configured threshold" {

            Mock -CommandName Get-WmiObject -MockWith {
                return @(
                    [ServerTimeMock]::new('Server1', [datetime]::new(2017, 1, 1, 10, 15, 0), [datetime]::new(2016, 1, 1, 10, 15, 0))
                    [ServerTimeMock]::new('Server2', [datetime]::new(2017, 1, 1, 10, 15, 0), [datetime]::new(2016, 1, 1, 10, 15, 0))
                    [ServerTimeMock]::new('Server3', [datetime]::new(2017, 1, 1, 09, 48, 0), [datetime]::new(2016, 1, 1, 10, 15, 0))
                    [ServerTimeMock]::new('Server4', [datetime]::new(2017, 1, 1, 10, 15, 0), [datetime]::new(2016, 1, 1, 10, 15, 0))
                )
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General -ServerNames 'Server1'
                            OperatingSystem -AllowedMinutesVarianceBetweenServerTimes 31
                        }

            $actual = Test-ComputerTime $poShMonConfiguration

            $actual.NoIssuesFound | Should Be $true

            $actual.OutputValues.Highlight.Count | Should Be 0
        }

         It "Should warn on server times with differences above configured threshold" {

            Mock -CommandName Get-WmiObject -MockWith {
                return @(
                    [ServerTimeMock]::new('Server1', [datetime]::new(2017, 1, 1, 10, 15, 0), [datetime]::new(2016, 1, 1, 10, 15, 0))
                    [ServerTimeMock]::new('Server2', [datetime]::new(2017, 1, 1, 10, 12, 0), [datetime]::new(2016, 1, 1, 10, 15, 0))
                    [ServerTimeMock]::new('Server3', [datetime]::new(2017, 1, 1, 10, 15, 0), [datetime]::new(2016, 1, 1, 10, 15, 0))
                )
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General -ServerNames 'Server1'
                            OperatingSystem -AllowedMinutesVarianceBetweenServerTimes 2
                        }

            $actual = Test-ComputerTime $poShMonConfiguration -WarningAction SilentlyContinue

            $actual.NoIssuesFound | Should Be $false

            $actual.OutputValues.Highlight.Count | Should Be 3
            $actual.OutputValues.Highlight[0] | Should Be "CurrentTime"
        }

         It "Should not warn on server times with differences within default threshold across hour boundaries" {

            Mock -CommandName Get-WmiObject -MockWith {
                return @(
                    [ServerTimeMock]::new('Server1', [datetime]::new(2017, 1, 1, 11, 01, 0), [datetime]::new(2016, 1, 1, 10, 15, 0))
                    [ServerTimeMock]::new('Server2', [datetime]::new(2017, 1, 1, 10, 59, 0), [datetime]::new(2016, 1, 1, 10, 15, 0))
                    [ServerTimeMock]::new('Server3', [datetime]::new(2017, 1, 1, 11, 01, 0), [datetime]::new(2016, 1, 1, 10, 15, 0))
                )
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General -ServerNames 'Server1'
                            OperatingSystem -AllowedMinutesVarianceBetweenServerTimes 3
                        }

            $actual = Test-ComputerTime $poShMonConfiguration

            $actual.NoIssuesFound | Should Be $true
        }

        It "Should not warn on server times with differences within default threshold across day boundaries" {

            Mock -CommandName Get-WmiObject -MockWith {
                return @(
                    [ServerTimeMock]::new('Server1', [datetime]::new(2017, 1, 2, 00, 01, 0), [datetime]::new(2016, 1, 1, 10, 15, 0))
                    [ServerTimeMock]::new('Server2', [datetime]::new(2017, 1, 1, 23, 59, 0), [datetime]::new(2016, 1, 1, 10, 15, 0))
                    [ServerTimeMock]::new('Server3', [datetime]::new(2017, 1, 2, 00, 01, 0), [datetime]::new(2016, 1, 1, 10, 15, 0))
                )
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General -ServerNames 'Server1'
                            OperatingSystem -AllowedMinutesVarianceBetweenServerTimes 3
                        }

            $actual = Test-ComputerTime $poShMonConfiguration

            $actual.NoIssuesFound | Should Be $true
        }

    It "Should only warn servers recently rebooted" {

            Mock -CommandName Get-WmiObject -MockWith {
                return @(
                    [ServerTimeMock]::new('Server1', [datetime]::new(2017, 1, 2, 00, 01, 0), [datetime]::new(2016, 1, 1, 10, 15, 0))
                    [ServerTimeMock]::new('Server2', [datetime]::new(2017, 1, 1, 23, 59, 0), [datetime]::new(2017, 1, 1, 10, 5, 0))
                    [ServerTimeMock]::new('Server3', [datetime]::new(2017, 1, 2, 00, 01, 0), [datetime]::new(2016, 1, 1, 10, 15, 0))
                )
            }

            Mock -CommandName Get-Date -MockWith {
                Return [datetime]::new(2017, 1, 1, 10, 15, 0)
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General -ServerNames 'Server1'
                            OperatingSystem -AllowedMinutesVarianceBetweenServerTimes 3
                        }

            $actual = Test-ComputerTime $poShMonConfiguration -WarningAction SilentlyContinue

            $actual.NoIssuesFound | Should Be $false
            $actual.OutputValues[2].Highlight | Should Be "LastBootUptime"
        }
    }
}