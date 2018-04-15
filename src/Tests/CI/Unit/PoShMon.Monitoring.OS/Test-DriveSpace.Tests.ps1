$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\..\..\') -Resolve
Remove-Module PoShMon -ErrorAction SilentlyContinue
Import-Module (Join-Path $rootPath -ChildPath "PoShMon.psd1")

Describe "Test-DriveSpace" {
    InModuleScope PoShMon {

        class DiskMock {
			[string]$DeviceID
            [int]$DriveType
            [string]$ProviderName
            [UInt64]$Size
            [UInt64]$FreeSpace
            [string]$VolumeName

            DiskMock ([string]$NewDeviceID, [int]$NewDriveType, [String]$NewProviderName, [UInt64]$NewSize, [UInt64]$NewFreeSpace, [String]$NewVolumeName) {
				$this.DeviceID = $NewDeviceID;
                $this.DriveType = $NewDriveType;
                $this.ProviderName = $NewProviderName;
                $this.Size = $NewSize;
                $this.FreeSpace = $NewFreeSpace;
                $this.VolumeName = $NewVolumeName;
            }
        }

        #It "Should throw an exception if no OperatingSystem configuration is set" {
        #
        #    $poShMonConfiguration = New-PoShMonConfiguration {
        #                }
        #
        #    { Test-DriveSpace $poShMonConfiguration } | Should throw
        #}

        It "Should return a matching output structure" {
    
            Mock -CommandName Get-WmiObject -MockWith {
                return [DiskMock]::new('C:', 3, "", [UInt64]50GB, [UInt64]15GB, "MyCDrive")
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General -ServerNames 'localhost'
                            OperatingSystem -DriveSpaceThreshold 0 # zero will trigger the default, 10 (GB)
                        }

            $actual = Test-DriveSpace $poShMonConfiguration

            $actual.Keys.Count | Should Be 6
            $actual.ContainsKey("NoIssuesFound") | Should Be $true
            $actual.ContainsKey("OutputHeaders") | Should Be $true
            $actual.ContainsKey("OutputValues") | Should Be $true
            $actual.ContainsKey("SectionHeader") | Should Be $true
            $actual.ContainsKey("ElapsedTime") | Should Be $true
            $actual.ContainsKey("GroupBy") | Should Be $true
            $headers = $actual.OutputHeaders
            $headers.Keys.Count | Should Be 4
            #$valuesGroup1 = $actual.OutputValues[0]
            #$valuesGroup1.Keys.Count | Should Be 2
            #$values1 = $valuesGroup1.GroupOutputValues[0]
            #$values1.Keys.Count | Should Be 4
            #$values1.ContainsKey("DriveLetter") | Should Be $true
            #$values1.ContainsKey("TotalSpace") | Should Be $true
            #$values1.ContainsKey("FreeSpace") | Should Be $true
            #$values1.ContainsKey("Highlight") | Should Be $true
            $actual.OutputValues[0].DriveLetter | Should Be "C:"
            $actual.OutputValues[0].DriveName | Should Be "MyCDrive"
            $actual.OutputValues[0].TotalSpace | Should Be "50.00"
            $actual.OutputValues[0].FreeSpace | Should Be "15.00 (30%)"
            $actual.OutputValues[0].Highlight.Count | Should Be 0
        }

        It "Should write the expected Verbose output (fixed)" {
    
            Mock -CommandName Get-WmiObject -MockWith {
                return [DiskMock]::new('C:', 3, "", [UInt64]50GB, [UInt64]13.76GB, "MyCDrive")
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General -ServerNames 'localhost'
                            OperatingSystem # zero will trigger the default, 10 (GB)
                        }

            $actual = Test-DriveSpace $poShMonConfiguration -Verbose
            $output = $($actual = Test-DriveSpace $poShMonConfiguration -Verbose) 4>&1

            $output.Count | Should Be 4
            $output[0].ToString() | Should Be "Initiating 'Harddrive Space Review' Test..."
            $output[1].ToString() | Should Be "`tlocalhost"
            $output[2].ToString() | Should Be "`t`tC: : 50.00 : 13.76 (28%)"
            $output[3].ToString() | Should Be "Complete 'Harddrive Space Review' Test, Issues Found: No"
        }

        It "Should write the expected Warning output (fixed)" {
    
            Mock -CommandName Get-WmiObject -MockWith {
                return [DiskMock]::new('C:', 3, "", [UInt64]50GB, [UInt64]5.143GB, "MyCDrive")
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General -ServerNames 'Server1'
                            OperatingSystem -DriveSpaceThreshold 0 # zero will trigger the default, 10 (GB)
                        }

            $actual = Test-DriveSpace $poShMonConfiguration
            $output = $($actual = Test-DriveSpace $poShMonConfiguration) 3>&1

            $output.Count | Should Be 1
            $output[0].ToString() | Should Be "`t`tFree drive Space (5.14) is below variance threshold (10)"
        }

        It "Should write the expected Warning output (percent)" {
    
            Mock -CommandName Get-WmiObject -MockWith {
                return [DiskMock]::new('C:', 3, "", [UInt64]50GB, [UInt64]5.945GB, "MyCDrive")
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General -ServerNames 'Server1'
                            OperatingSystem -DriveSpaceThresholdPercent 95 # zero will trigger the default, 10 (GB)
                        }

            $actual = Test-DriveSpace $poShMonConfiguration
            $output = $($actual = Test-DriveSpace $poShMonConfiguration) 3>&1

            $output.Count | Should Be 1
            $output[0].ToString() | Should Be "`t`tFree drive Space (12%) is below variance threshold (95%)"
        }
        It "Should not warn on space above threshold" {

            Mock -CommandName Get-WmiObject -MockWith {
                return [DiskMock]::new('C:', 3, "", [UInt64]50GB, [UInt64]11GB, "MyCDrive")
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General -ServerNames 'localhost'
                            OperatingSystem -DriveSpaceThreshold 0 # zero will trigger the default, 10 (GB)
                        }

            $actual = Test-DriveSpace $poShMonConfiguration
        
            $actual.NoIssuesFound | Should Be $true

            $actual.OutputValues.GroupOutputValues.Highlight.Count | Should Be 0
        }

        It "Should warn on space below threshold (default)" {

            Mock -CommandName Get-WmiObject -MockWith {
                return [DiskMock]::new('C:', 3, "", [UInt64]50GB, [UInt64]5GB, "MyCDrive")
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General -ServerNames 'localhost'
                            OperatingSystem -DriveSpaceThreshold 0 # zero will trigger the default, 10 (GB)
                        }

            $actual = Test-DriveSpace $poShMonConfiguration -WarningAction SilentlyContinue
        
            $actual.NoIssuesFound | Should Be $false

            $actual.OutputValues.Highlight.Count | Should Be 1
            $actual.OutputValues.Highlight | Should Be 'FreeSpace'
        }

        It "Should warn on space below specified threshold (fixed)" {

            Mock -CommandName Get-WmiObject -MockWith {
                return [DiskMock]::new('C:', 3, "", [UInt64]50GB, [UInt64]15GB, "MyCDrive")
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General -ServerNames 'localhost'
                            OperatingSystem -DriveSpaceThreshold 20
                        }

            $actual = Test-DriveSpace $poShMonConfiguration -WarningAction SilentlyContinue
        
            $actual.NoIssuesFound | Should Be $false

            $actual.OutputValues.Highlight.Count | Should Be 1
            $actual.OutputValues.Highlight | Should Be 'FreeSpace'
        }

        It "Should warn on space above specified threshold (percent)" {

            Mock -CommandName Get-WmiObject -MockWith {
                return @(
                        [DiskMock]::new('C:', 3, "", [UInt64]50GB, [UInt64]21GB, "MyCDrive")
                        [DiskMock]::new('D:', 3, "", [UInt64]50GB, [UInt64]44GB, "MyEDrive")
                        )
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General -ServerNames 'localhost'
                            OperatingSystem -DriveSpaceThresholdPercent 50
                        }

            $actual = Test-DriveSpace $poShMonConfiguration -WarningAction SilentlyContinue
        
            $actual.NoIssuesFound | Should Be $false

            $actual.OutputValues.Highlight.Count | Should Be 1
            $actual.OutputValues.Highlight | Should Be 'FreeSpace'
        }

        It "Should not warn on space below specified threshold (percent)" {

            Mock -CommandName Get-WmiObject -MockWith {
                return [DiskMock]::new('C:', 3, "", [UInt64]50GB, [UInt64]15GB, "MyCDrive")
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General -ServerNames 'localhost'
                            OperatingSystem -DriveSpaceThresholdPercent 5
                        }

            $actual = Test-DriveSpace $poShMonConfiguration -WarningAction SilentlyContinue
        
            $actual.NoIssuesFound | Should Be $true

            $actual.OutputValues.GroupOutputValues.Highlight.Count | Should Be 0
        }
    }
}