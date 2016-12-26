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

Describe "Test-DriveSpace" {
    It "Should not warn on space above threshold" {
        
        $expected = @{
            "NoIssuesFound" = $true;
            "OutputHeaders" = @{ 'DriveLetter' = 'Drive Letter'; 'TotalSpace' = 'Total Space (GB)'; 'FreeSpace' = 'Free Space (GB)' };
            "OutputValues" = @()
            }

        $expected["OutputValues"] += @{
                        'DriveLetter' = 'C:';
                        'TotalSpace' = 243631;
                        'FreeSpace' = 58313;
                        'Highlight' = ''
                    }

        #Mock -CommandName Format-Gigs -MockWith {
        #    return '123'
        #}

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