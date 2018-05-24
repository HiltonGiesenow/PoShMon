$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\..\..\') -Resolve
Remove-Module PoShMon -ErrorAction SilentlyContinue
Import-Module (Join-Path $rootPath -ChildPath "PoShMon.psd1")

Describe "Test-CPULoad" {
    InModuleScope PoShMon {

        class CounterSampleMock {
            [string]$Path
            [double]$CookedValue

            CounterSampleMock ([string]$NewPath, [double]$NewCookedValue) {
                $this.Path = $NewPath;
                $this.CookedValue = $NewCookedValue;
            }
        }

        class CounterResultsMock {
            [datetime]$Timestamp
            [CounterSampleMock[]]$CounterSamples

            CounterResultsMock ([datetime]$NewTimestamp, [CounterSampleMock[]]$NewCounterSamples) {
                $this.Timestamp = $NewTimestamp;
                $this.CounterSamples = $NewCounterSamples;
            }
        }
        
        #It "Should throw an exception if no OperatingSystem configuration is set" {
        #
        #    $poShMonConfiguration = New-PoShMonConfiguration { }
        #
        #    { Test-CPULoad $poShMonConfiguration } | Should throw
        #}

        It "Should return a matching output structure" {
    
            Mock -CommandName Get-Counter -MockWith {
                $sample1 = [CounterSampleMock]::new("\\Server1\processor(_total)\% processor time", 12.345)
                $sample2 = [CounterSampleMock]::new("\\Server1\processor(_total)\% processor time", 56.789)
                $samples = @($sample1, $sample2)
                $timestamp = Get-Date
                return [CounterResultsMock]::new($timestamp, $samples)
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General -ServerNames '.'
                            OperatingSystem
                        }

            $actual = Test-CPULoad $poShMonConfiguration

            $actual.Keys.Count | Should Be 5
            $actual.ContainsKey("NoIssuesFound") | Should Be $true
            $actual.ContainsKey("OutputHeaders") | Should Be $true
            $actual.ContainsKey("OutputValues") | Should Be $true
            $actual.ContainsKey("SectionHeader") | Should Be $true
            $actual.ContainsKey("ElapsedTime") | Should Be $true
            $headers = $actual.OutputHeaders
            $headers.Keys.Count | Should Be 2
            $actual.OutputValues[1].ServerName | Should Be 'Server1'
            $actual.OutputValues[1].CPULoad | Should Be '57%'
            $actual.OutputValues[1].Highlight.Count | Should Be 0
            #$values1 = $actual.OutputValues[0]
            #$values1.Keys.Count | Should Be 3
            #$values1.ContainsKey("ServerName") | Should Be $true
            #$values1.ContainsKey("CPULoad") | Should Be $true
            #$values1.ContainsKey("Highlight") | Should Be $true
        }

        It "Should write the expected Verbose output" {
    
            Mock -CommandName Get-Counter -MockWith {
                $sample1 = [CounterSampleMock]::new("\\Server1\processor(_total)\% processor time", 12.345)
                $sample2 = [CounterSampleMock]::new("\\Server2\processor(_total)\% processor time", 56.789)
                $samples = @($sample1, $sample2)
                $timestamp = Get-Date
                return [CounterResultsMock]::new($timestamp, $samples)
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General -ServerNames '.'
                            OperatingSystem
                        }

            $actual = Test-CPULoad $poShMonConfiguration -Verbose
            $output = $($actual = Test-CPULoad $poShMonConfiguration -Verbose) 4>&1

            $output.Count | Should Be 4
            $output[0].ToString() | Should Be "Initiating 'Server CPU Load Review' Test..."
            $output[1].ToString() | Should Be "`tSERVER1: 12%"
            $output[2].ToString() | Should Be "`tSERVER2: 57%"
            $output[3].ToString() | Should Be "Complete 'Server CPU Load Review' Test, Issues Found: No"
        }

        It "Should write the expected Warning output" {
    
            Mock -CommandName Get-Counter -MockWith {
                $sample1 = [CounterSampleMock]::new("\\Server1\processor(_total)\% processor time", 12.345)
                $sample2 = [CounterSampleMock]::new("\\Server1\processor(_total)\% processor time", 97.789)
                $samples = @($sample1, $sample2)
                $timestamp = Get-Date
                return [CounterResultsMock]::new($timestamp, $samples)
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General -ServerNames '.'
                            OperatingSystem
                        }

            $output = $($actual = Test-CPULoad $poShMonConfiguration) 3>&1

            $output.Count | Should Be 1
            $output[0].ToString() | Should Be "`tCPU Load (98%) is above variance threshold (90%)"
        }

        It "Should not warn on CPU below threshold" {

            Mock -CommandName Get-Counter -MockWith {
                $sample1 = [CounterSampleMock]::new("\\Server1\processor(_total)\% processor time", 12.345)
                $sample2 = [CounterSampleMock]::new("\\Server1\processor(_total)\% processor time", 56.789)
                $samples = @($sample1, $sample2)
                $timestamp = Get-Date
                return [CounterResultsMock]::new($timestamp, $samples)
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General -ServerNames 'localhost'
                            OperatingSystem
                        }

            $actual = Test-CPULoad $poShMonConfiguration
        
            $actual.NoIssuesFound | Should Be $true

            $actual.OutputValues.GroupOutputValues.Highlight.Count | Should Be 0
        }

        It "Should warn on CPU above threshold" {
        
            Mock -CommandName Get-Counter -MockWith {
                $sample1 = [CounterSampleMock]::new("\\Server1\processor(_total)\% processor time", 12.345)
                $sample2 = [CounterSampleMock]::new("\\Server1\processor(_total)\% processor time", 97.789)
                $samples = @($sample1, $sample2)
                $timestamp = Get-Date
                return [CounterResultsMock]::new($timestamp, $samples)
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General -ServerNames 'localhost'
                            OperatingSystem
                        }

            $actual = Test-CPULoad $poShMonConfiguration
        
            $actual.NoIssuesFound | Should Be $false

            $actual.OutputValues.Highlight.Count | Should Be 1
            $actual.OutputValues.Highlight | Should Be 'CPULoad'
        }
        It "Should use the configuration threshold properly" {
        
            Mock -CommandName Get-Counter -MockWith {
                $sample1 = [CounterSampleMock]::new("\\Server1\processor(_total)\% processor time", 12.345)
                $sample2 = [CounterSampleMock]::new("\\Server1\processor(_total)\% processor time", 57.789)
                $samples = @($sample1, $sample2)
                $timestamp = Get-Date
                return [CounterResultsMock]::new($timestamp, $samples)
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General -ServerNames 'localhost'
                            OperatingSystem -CPULoadThresholdPercent 50
                        }

            $actual = Test-CPULoad $poShMonConfiguration
        
            $actual.NoIssuesFound | Should Be $false

            $actual.OutputValues.Highlight.Count | Should Be 1
            $actual.OutputValues.Highlight | Should Be 'CPULoad'
		}
	}
}
Describe "Test-CPULoad-Scope2" {
    InModuleScope PoShMon {

        class CounterSampleMock {
            [string]$Path
            [double]$CookedValue

            CounterSampleMock ([string]$NewPath, [double]$NewCookedValue) {
                $this.Path = $NewPath;
                $this.CookedValue = $NewCookedValue;
            }
        }

        class CounterResultsMock {
            [datetime]$Timestamp
            [CounterSampleMock[]]$CounterSamples

            CounterResultsMock ([datetime]$NewTimestamp, [CounterSampleMock[]]$NewCounterSamples) {
                $this.Timestamp = $NewTimestamp;
                $this.CounterSamples = $NewCounterSamples;
            }
        }

        It "Should call 'Get-Counter' with Computername for all computers if none is the current machine" {
        
            Mock -CommandName Get-Counter -ParameterFilter { $Computername -eq $null } -MockWith {
				return
            }

			Mock -CommandName Get-Counter -ParameterFilter { $Computername -eq "TestOtherServer1" -and $Computername -eq "TestOtherServer2" } -MockWith {
				$samples = @()
				
				foreach ($computer in $Computername)
				{
					$samples += [CounterSampleMock]::new("\\$computer\\processor(_total)\% processor time", 12.345)
				}

                return [CounterResultsMock]::new((Get-Date), $samples)
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General -ServerNames "TestOtherServer1","TestOtherServer2"
                            OperatingSystem 
                        }

            $actual = Test-CPULoad $poShMonConfiguration -Verbose
        
			$actual.OutputValues.Count | Should Be 2

			Assert-MockCalled -CommandName Get-Counter -ParameterFilter { $Computername -eq $null } -Times 0
			Assert-MockCalled -CommandName Get-Counter -ParameterFilter { $Computername -eq "TestOtherServer1" -and $Computername -eq "TestOtherServer2" } -Times 1
		}
	}
}
Describe "Test-CPULoad-Scope2" {
    InModuleScope PoShMon {

        class CounterSampleMock {
            [string]$Path
            [double]$CookedValue

            CounterSampleMock ([string]$NewPath, [double]$NewCookedValue) {
                $this.Path = $NewPath;
                $this.CookedValue = $NewCookedValue;
            }
        }

        class CounterResultsMock {
            [datetime]$Timestamp
            [CounterSampleMock[]]$CounterSamples

            CounterResultsMock ([datetime]$NewTimestamp, [CounterSampleMock[]]$NewCounterSamples) {
                $this.Timestamp = $NewTimestamp;
                $this.CounterSamples = $NewCounterSamples;
            }
        }

        It "Should only call 'Get-Counter' with 'Computername' parameter for computers other than the current machine" {
        
            Mock -CommandName Get-Counter -ParameterFilter { $Computername -eq $null } -MockWith {
				if ($Computername -eq $null) { $Computername = $Env:COMPUTERNAME }
                $sample1 = [CounterSampleMock]::new("\\$Computername\processor(_total)\% processor time", 12.345)
                $timestamp = Get-Date
                return [CounterResultsMock]::new($timestamp, $sample1)
            }

			Mock -CommandName Get-Counter -ParameterFilter { $Computername -eq "TestOtherServer" } -MockWith {
				if ($Computername -eq $null) { $Computername = $Env:COMPUTERNAME }
                $sample1 = [CounterSampleMock]::new("\\$Computername\\processor(_total)\% processor time", 12.345)
                $timestamp = Get-Date
                return [CounterResultsMock]::new($timestamp, $sample1)
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General -ServerNames ($env:COMPUTERNAME.ToLower(),"TestOtherServer")
                            OperatingSystem 
                        }

            $actual = Test-CPULoad $poShMonConfiguration -Verbose
        
			$actual.OutputValues.Count | Should Be 2

			Assert-MockCalled -CommandName Get-Counter -ParameterFilter { $Computername -eq $null } -Times 1 -Exactly
			Assert-MockCalled -CommandName Get-Counter -ParameterFilter { $Computername -eq "TestOtherServer" } -Times 1 -Exactly
		}
	}
}
Describe "Test-CPULoad-Scope3" {
    InModuleScope PoShMon {

        class CounterSampleMock {
            [string]$Path
            [double]$CookedValue

            CounterSampleMock ([string]$NewPath, [double]$NewCookedValue) {
                $this.Path = $NewPath;
                $this.CookedValue = $NewCookedValue;
            }
        }

        class CounterResultsMock {
            [datetime]$Timestamp
            [CounterSampleMock[]]$CounterSamples

            CounterResultsMock ([datetime]$NewTimestamp, [CounterSampleMock[]]$NewCounterSamples) {
                $this.Timestamp = $NewTimestamp;
                $this.CounterSamples = $NewCounterSamples;
            }
        }

        It "Should only call 'Get-Counter' with 'Computername' parameter for computers other than the current machine - 3 in total" {
        
            Mock -CommandName Get-Counter -ParameterFilter { $Computername -eq $null } -MockWith {
				if ($Computername -eq $null) { $Computername = $Env:COMPUTERNAME }
                $sample1 = [CounterSampleMock]::new("\\$Computername\processor(_total)\% processor time", 12.345)
                $timestamp = Get-Date
                return [CounterResultsMock]::new($timestamp, $sample1)
            }

			Mock -CommandName Get-Counter -ParameterFilter { $Computername -eq "TestOtherServer1" -or $Computername -eq "TestOtherServer2" } -MockWith {
				$samples = @()
				foreach ($computer in $Computername)
				{
					$samples += [CounterSampleMock]::new("\\$computer\\processor(_total)\% processor time", 12.345)
				}
                return [CounterResultsMock]::new((Get-Date), $samples)
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General -ServerNames ($env:COMPUTERNAME.ToLower(),"TestOtherServer1","TestOtherServer2")
                            OperatingSystem 
                        }

            $actual = Test-CPULoad $poShMonConfiguration -Verbose
        
			$actual.OutputValues.Count | Should Be 3

			Assert-MockCalled -CommandName Get-Counter -ParameterFilter { $Computername -eq $null } -Times 1 -Exactly
			Assert-MockCalled -CommandName Get-Counter -ParameterFilter { $Computername -eq "TestOtherServer1" -or $Computername -eq "TestOtherServer2" } -Times 1 -Exactly
		}
	}
}
Describe "Test-CPULoad-Scope4" {
    InModuleScope PoShMon {

        class CounterSampleMock {
            [string]$Path
            [double]$CookedValue

            CounterSampleMock ([string]$NewPath, [double]$NewCookedValue) {
                $this.Path = $NewPath;
                $this.CookedValue = $NewCookedValue;
            }
        }

        class CounterResultsMock {
            [datetime]$Timestamp
            [CounterSampleMock[]]$CounterSamples

            CounterResultsMock ([datetime]$NewTimestamp, [CounterSampleMock[]]$NewCounterSamples) {
                $this.Timestamp = $NewTimestamp;
                $this.CounterSamples = $NewCounterSamples;
            }
        }

        It "Should only call 'Get-Counter' without 'Computername' parameter for current machine" {
        
            Mock -CommandName Get-Counter -ParameterFilter { $Computername -eq $null } -MockWith {
				if ($Computername -eq $null) { $Computername = $Env:COMPUTERNAME }
                $sample1 = [CounterSampleMock]::new("\\$Computername\processor(_total)\% processor time", 12.345)
                $timestamp = Get-Date
                return [CounterResultsMock]::new($timestamp, $sample1)
            }

			Mock -CommandName Get-Counter -ParameterFilter { $Computername -ne $null } -MockWith {
				if ($Computername -eq $null) { $Computername = $Env:COMPUTERNAME }
                $sample1 = [CounterSampleMock]::new("\\$Computername\\processor(_total)\% processor time", 12.345)
                $timestamp = Get-Date
                return [CounterResultsMock]::new($timestamp, $sample1)
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General -ServerNames ($env:COMPUTERNAME.ToLower())
                            OperatingSystem 
                        }

            $actual = Test-CPULoad $poShMonConfiguration -Verbose
        
			$actual.OutputValues.Count | Should Be 1

			Assert-MockCalled -CommandName Get-Counter -ParameterFilter { $Computername -eq $null } -Times 1
			Assert-MockCalled -CommandName Get-Counter -ParameterFilter { $Computername -ne $null } -Times 0
		}

    }
}