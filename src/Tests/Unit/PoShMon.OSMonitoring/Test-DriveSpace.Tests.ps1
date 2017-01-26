
$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\..\') -Resolve
Remove-Module PoShMon -ErrorAction SilentlyContinue
Import-Module (Join-Path $rootPath -ChildPath "PoShMon.psd1") -Verbose

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

Describe "Test-DriveSpace" {
    It "Should throw an exception if no OperatingSystem configuration is set" {
    
        $poShMonConfiguration = New-PoShMonConfiguration {
                    }

        { Test-DriveSpace $poShMonConfiguration } | Should throw
    }

    It "Should return a matching output structure" {
    
        Mock -CommandName Get-WmiObject -MockWith {
            return [DiskMock]::new('C:', 3, "", [UInt64]50GB, [UInt64]15GB, "MyCDrive")
        }

        $poShMonConfiguration = New-PoShMonConfiguration {
                        General -ServerNames 'localhost'
                        OperatingSystem
                    }

        $actual = Test-DriveSpace $poShMonConfiguration

        $actual.Keys.Count | Should Be 5
        $actual.ContainsKey("NoIssuesFound") | Should Be $true
        $actual.ContainsKey("OutputHeaders") | Should Be $true
        $actual.ContainsKey("OutputValues") | Should Be $true
        $actual.ContainsKey("SectionHeader") | Should Be $true
        $actual.ContainsKey("ElapsedTime") | Should Be $true
        $headers = $actual.OutputHeaders
        $headers.Keys.Count | Should Be 3
        $valuesGroup1 = $actual.OutputValues[0]
        $valuesGroup1.Keys.Count | Should Be 2
        $values1 = $valuesGroup1.GroupOutputValues[0]
        $values1.Keys.Count | Should Be 4
        $values1.ContainsKey("DriveLetter") | Should Be $true
        $values1.ContainsKey("TotalSpace") | Should Be $true
        $values1.ContainsKey("FreeSpace") | Should Be $true
        $values1.ContainsKey("Highlight") | Should Be $true
    }

    It "Should write the expected Verbose output" {
    
        Mock -CommandName Get-WmiObject -MockWith {
            return [DiskMock]::new('C:', 3, "", [UInt64]50GB, [UInt64]15GB, "MyCDrive")
        }

        $poShMonConfiguration = New-PoShMonConfiguration {
                        General -ServerNames 'localhost'
                        OperatingSystem
                    }

        $actual = Test-DriveSpace $poShMonConfiguration -Verbose
        $output = $($actual = Test-DriveSpace $poShMonConfiguration -Verbose) 4>&1

        $output.Count | Should Be 4
        $output[0].ToString() | Should Be "Initiating 'Harddrive Space Review' Test..."
        $output[1].ToString() | Should Be "`tlocalhost"
        $output[2].ToString() | Should Be "`t`tC: : 50.00 : 15.00"
        $output[3].ToString() | Should Be "Complete 'Harddrive Space Review' Test"
    }

    It "Should write the expected Warning output" {
    
        Mock -CommandName Get-WmiObject -MockWith {
            return [DiskMock]::new('C:', 3, "", [UInt64]50GB, [UInt64]5GB, "MyCDrive")
        }

        $poShMonConfiguration = New-PoShMonConfiguration {
                        General -ServerNames 'Server1'
                        OperatingSystem
                    }

        $actual = Test-DriveSpace $poShMonConfiguration -Verbose
        $output = $($actual = Test-DriveSpace $poShMonConfiguration) 3>&1

        $output.Count | Should Be 1
        $output[0].ToString() | Should Be "`t`tFree drive Space (5) is below variance threshold (10)"
    }

    It "Should not warn on space above threshold" {

        Mock -CommandName Get-WmiObject -MockWith {
            return [DiskMock]::new('C:', 3, "", [UInt64]50GB, [UInt64]11GB, "MyCDrive")
        }

        $poShMonConfiguration = New-PoShMonConfiguration {
                        General -ServerNames 'localhost'
                        OperatingSystem
                    }

        $actual = Test-DriveSpace $poShMonConfiguration
        
        $actual.NoIssuesFound | Should Be $true

        $actual.OutputValues.GroupOutputValues.Highlight.Count | Should Be 0
    }

    It "Should warn on space below threshold" {

        Mock -CommandName Get-WmiObject -MockWith {
            return [DiskMock]::new('C:', 3, "", [UInt64]50GB, [UInt64]5GB, "MyCDrive")
        }

        $poShMonConfiguration = New-PoShMonConfiguration {
                        General -ServerNames 'localhost'
                        OperatingSystem
                    }

        $actual = Test-DriveSpace $poShMonConfiguration
        
        $actual.NoIssuesFound | Should Be $false

        $actual.OutputValues.GroupOutputValues.Highlight.Count | Should Be 1
        $actual.OutputValues.GroupOutputValues.Highlight[0] | Should Be 'FreeSpace'
    }
}