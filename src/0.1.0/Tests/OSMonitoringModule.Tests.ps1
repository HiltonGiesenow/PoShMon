$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$moduleFolderPath = Join-Path $here -ChildPath ('..\Modules\') -Resolve
#$sutFileName = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.ps1", ".psm1")
#$sut = Join-Path $sutFolderPath, $sutFileName
#. "$sut"
Import-Module (Join-Path $moduleFolderPath -ChildPath "PoShMon.Shared\SharedMonitoringModule.psm1")
Import-Module (Join-Path $moduleFolderPath -ChildPath "PoShMon.OSMonitoring\OSMonitoringModule.psm1")

Function TestArray
{
    param(
        [Array]$expected,
        $actual
    )

    $actual.GetType().Name | Should Be $expected.GetType().Name

    For ($i = 0; $i -le $expected[$key].Count; $i++) {
        if ($expected[$i].GetType().Name -eq 'Hashtable')
        {
            TestHashtable $expected[$i]  $actual[$i]
        }
        elseif ($expected[$key].GetType().Name.EndsWith('[]')) #basically any type of array
        {
            TestArray $expected[$i]  $actual[$i]
        }
        else
        {
            $actual[$key] | Should BeOfType $expected[$key].GetType().Name
            $actual[$key] | Should Be $expected[$key]
        }
    }
}

Function TestHashtable
{
    param(
        [Hashtable]$expected,
        $actual
    )

    $actual | Should BeOfType Hashtable
        
    foreach ($key in $expected.Keys)
    {
        if ($expected[$key] -eq $null)
            { Write-Host $key; $actual[$key] | Should BeNullOrEmpty }
        else
            { Write-Host $key; $actual[$key] | Should Not BeNullOrEmpty }

        if ($expected[$key].GetType().Name -eq 'Hashtable')
        {
            TestHashtable $expected[$key]  $actual[$key]
        }
        elseif ($expected[$key].GetType().Name.EndsWith('[]')) #basically any type of array
        {
            TestArray $expected[$key]  $actual[$key]
        }
        else
        {
            $actual[$key].GetType().Name | Should Be $expected[$key].GetType().Name
            $actual[$key] | Should Be $expected[$key]
        }
    }

    #$actual.NoIssuesFound | Should Be $expected.NoIssuesFound
    #$actual.OutputHeaders | Should BeOfType Hashtable
    #$actual.OutputHeaders.Count | Should Be $expected.Count
}

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

class EventLogItemMock {
    [int]$EventCode
    [string]$SourceName
    [string]$User
    [string]$TimeGenerated
    [string]$Message

    EventLogItemMock ([int]$NewEventCode, [String]$NewSourceName, [String]$NewUser, [String]$NewTimeGenerated, [String]$NewMessage) {
        $this.EventCode = $NewEventCode;
        $this.SourceName = $NewSourceName;
        $this.User = $NewUser;
        $this.TimeGenerated = $NewTimeGenerated;
        $this.Message = $NewMessage;
    }

    [string] ConvertToDateTime([string]$something) {
        return (Get-Date).ToString()
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

Describe "Test-EventLogs" {
    It "Should alert on items found" {
        
        $expected = @{
            "NoIssuesFound" = $true;
            "outputHeaders" = @{ 'EventID' = 'Event ID'; 'InstanceCount' = 'Count'; 'Source' = 'Source'; 'User' = 'User'; 'Timestamp' = 'Timestamp'; 'Message' ='Message' };
            "OutputValues" = @()
            }

        $expected["OutputValues"] += @{
                        'DriveLetter' = 'C:';
                        'TotalSpace' = 243631;
                        'FreeSpace' = 58313;
                        'Highlight' = ''
                    }

        Mock -CommandName Get-WmiObject -MockWith {
            $eventsCollection = @()

            $eventsCollection += [EventLogItemMock]::new(123, "Test App", "domain\user1", "123", "Sample Message")
            return $eventsCollection
        }

        $actual = Test-EventLogs -ServerNames 'Server1'
        
        $actual.NoIssuesFound | Should Be $false
    }
    It "Should group per server" {
        
        $expected = @{
            "NoIssuesFound" = $true;
            "outputHeaders" = @{ 'EventID' = 'Event ID'; 'InstanceCount' = 'Count'; 'Source' = 'Source'; 'User' = 'User'; 'Timestamp' = 'Timestamp'; 'Message' ='Message' };
            "OutputValues" = @()
            }

        $expected["OutputValues"] += @{
                        'DriveLetter' = 'C:';
                        'TotalSpace' = 243631;
                        'FreeSpace' = 58313;
                        'Highlight' = ''
                    }

        Mock -CommandName Get-WmiObject -MockWith {
            $eventsCollection = @()

            $eventsCollection += [EventLogItemMock]::new(123, "Test App", "domain\user1", "123", "Sample Message")
            $eventsCollection += [EventLogItemMock]::new(123, "Test App", "domain\user1", "123", "Sample Message")
            $eventsCollection += [EventLogItemMock]::new(123, "Test App", "domain\user1", "123", "Another Sample Message")
            $eventsCollection += [EventLogItemMock]::new(456, "Test App", "domain\user1", "123", "Different Event Code")

            return $eventsCollection
        }

        $actual = Test-EventLogs -ServerNames 'Server1','Server2'
        
        $actual.NoIssuesFound | Should Be $false

        $actual.OutputValues.Count  | Should Be 2
        $actual.OutputValues[0].GroupName  | Should Be 'Server1'
        $actual.OutputValues[1].GroupName  | Should Be 'Server2'
    }
    It "Should group on EventID and Message" {
        
        $expected = @{
            "NoIssuesFound" = $true;
            "outputHeaders" = @{ 'EventID' = 'Event ID'; 'InstanceCount' = 'Count'; 'Source' = 'Source'; 'User' = 'User'; 'Timestamp' = 'Timestamp'; 'Message' ='Message' };
            "OutputValues" = @()
            }

        $expected["OutputValues"] += @{
                        'DriveLetter' = 'C:';
                        'TotalSpace' = 243631;
                        'FreeSpace' = 58313;
                        'Highlight' = ''
                    }

        Mock -CommandName Get-WmiObject -MockWith {
            $eventsCollection = @()

            $eventsCollection += [EventLogItemMock]::new(123, "Test App", "domain\user1", "123", "Sample Message")
            $eventsCollection += [EventLogItemMock]::new(123, "Test App", "domain\user1", "123", "Sample Message")
            $eventsCollection += [EventLogItemMock]::new(123, "Test App", "domain\user1", "123", "Another Sample Message")
            $eventsCollection += [EventLogItemMock]::new(456, "Test App", "domain\user1", "123", "Different Event Code")

            return $eventsCollection
        }

        $actual = Test-EventLogs -ServerNames localhost
        
        $actual.NoIssuesFound | Should Be $false

        $actual.OutputValues[0].GroupOutputValues.Count | Should Be 3
        $actual.OutputValues[0].GroupOutputValues[0].InstanceCount | Should Be 2
        $actual.OutputValues[0].GroupOutputValues[1].InstanceCount | Should Be 1
        $actual.OutputValues[0].GroupOutputValues[2].InstanceCount | Should Be 1
    }
}
