$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\') -Resolve
$sutFileName = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests", "")
$sutFilePath = Join-Path $rootPath -ChildPath "Functions\PoShMon.OSMonitoring\$sutFileName" 
. $sutFilePath
$depFilePath = Join-Path $rootPath -ChildPath "Functions\PoShMon.Shared\Format-Gigs.ps1"
. $depFilePath

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
<#
Describe "Test-DriveSpace" {
    It "Should return a matching output structure" {
    
        Mock -CommandName Get-WmiObject -MockWith {
            return [DiskMock]::new('C:', 3, "", [UInt64]255465615360, [UInt64]61145096192, "MyCDrive")
        }

        $actual = Test-DriveSpace "localhost"

        $actual.Keys.Count | Should Be 5
        $actual.ContainsKey("NoIssuesFound") | Should Be $true
        $actual.ContainsKey("OutputHeaders") | Should Be $true
        $actual.ContainsKey("OutputValues") | Should Be $true
        $actual.ContainsKey("SectionHeader") | Should Be $true
        $actual.ContainsKey("ElapsedTime") | Should Be $true
        $headers = $actual.OutputHeaders
        $headers.Keys.Count | Should Be 3
        $headers.ContainsKey("DriveLetter") | Should Be $true
        $headers.ContainsKey("TotalSpace") | Should Be $true
        $headers.ContainsKey("FreeSpace") | Should Be $true
        $valuesGroup1 = $actual.OutputValues[0]
        $valuesGroup1.Keys.Count | Should Be 2
        $values1 = $valuesGroup1.GroupOutputValues
        $values1.Keys.Count | Should Be 4
        $values1.ContainsKey("DriveLetter") | Should Be $true
        $values1.ContainsKey("TotalSpace") | Should Be $true
        $values1.ContainsKey("FreeSpace") | Should Be $true
        $values1.ContainsKey("Highlight") | Should Be $true
    }

    It "Should not warn on space above threshold" {

        Mock -CommandName Get-WmiObject -MockWith {
            return [DiskMock]::new('C:', 3, "", [UInt64]255465615360, [UInt64]61145096192, "MyCDrive")
        }

        $actual = Test-DriveSpace "localhost"
        
        $actual.NoIssuesFound | Should Be $true

        $actual.OutputValues.GroupOutputValues.Highlight.Count | Should Be 0
    }

    It "Should warn on space below threshold" {
        
        $expected = @{
            "NoIssuesFound" = $true;
            "OutputHeaders" = @{ 'DriveLetter' = 'Drive Letter'; 'TotalSpace' = 'Total Space (GB)'; 'FreeSpace' = 'Free Space (GB)' };
            "OutputValues" = @()
            }

        $expected["OutputValues"] += @{
                        'DriveLetter' = 'C:';
                        'TotalSpace' = 243631;
                        'FreeSpace' = 10;
                        'Highlight' = ''
                    }

        #Mock -CommandName Format-Gigs -MockWith {
        #    return '123'
        #}

        Mock -CommandName Get-WmiObject -MockWith {
            return [DiskMock]::new('C:', 3, "", [UInt64]255465615360, [UInt64]10485760, "MyCDrive")
        }

        $actual = Test-DriveSpace "localhost"
        
        $actual.NoIssuesFound | Should Be $false

        $actual.OutputValues.GroupOutputValues.Highlight.Count | Should Be 1
        $actual.OutputValues.GroupOutputValues.Highlight[0] | Should Be 'FreeSpace'
    }
}
#>